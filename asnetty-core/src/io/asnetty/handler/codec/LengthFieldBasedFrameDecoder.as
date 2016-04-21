package io.asnetty.handler.codec {

import flash.errors.IllegalOperationError;
import flash.utils.ByteArray;
import flash.utils.Endian;

import io.asnetty.channel.IChannelHandlerContext;

/**
 * @author Jeremy
 */
public class LengthFieldBasedFrameDecoder extends ByteToMessageDecoder {

    private var _byteOrder:String;
    private var _maxFrameLength:int;
    private var _lengthFieldOffset:int;
    private var _lengthFieldLength:int;
    private var _lengthFieldEndOffset:int;
    private var _lengthAdjustment:int;
    private var _initialBytesToStrip:int;
    private var _failFast:Boolean;
    private var _discardingTooLongFrame:Boolean;
    private var _tooLongFrameLength:Number;
    private var _bytesToDiscard:Number;

    public function LengthFieldBasedFrameDecoder(maxFrameLength:int, lengthFieldOffset:int, lengthFieldLength:int, lengthAdjustment:int = 0, initialBytesToStrip:int = 0, failFast:Boolean = true, byteOrder:String = Endian.BIG_ENDIAN) {
        super();

        byteOrder = byteOrder || Endian.BIG_ENDIAN;

        if (maxFrameLength <= 0)
            throw new ArgumentError("maxFrameLength must be a positive integer: " + maxFrameLength);

        if (lengthFieldOffset < 0)
            throw new ArgumentError("lengthFieldOffset must be a non-negative integer: " + lengthFieldOffset);

        if (initialBytesToStrip < 0)
            throw new ArgumentError("initialBytesToStrip must be a non-negative integer: " + initialBytesToStrip);

        if (lengthFieldOffset > maxFrameLength - lengthFieldLength)
            throw new ArgumentError("maxFrameLength (" + maxFrameLength + ") " +
                    "must be equal to or greater than " +
                    "lengthFieldOffset (" + lengthFieldOffset + ") + " +
                    "lengthFieldLength (" + lengthFieldLength + ").");

        this._byteOrder = byteOrder;
        this._maxFrameLength = maxFrameLength;
        this._lengthFieldOffset = lengthFieldOffset;
        this._lengthFieldLength = lengthFieldLength;
        this._lengthFieldEndOffset = lengthFieldOffset + lengthFieldLength;
        this._lengthAdjustment = lengthAdjustment;
        this._initialBytesToStrip = initialBytesToStrip;
        this._failFast = failFast;
    }

    override protected final function decode(ctx:IChannelHandlerContext, inBuf:ByteArray, out:Vector.<Object>):void {
        const decoded:Object = doDecode(ctx, inBuf);
        if (decoded) {
            out.push(decoded);
        }
    }

    protected function doDecode(ctx:IChannelHandlerContext, inBuf:ByteArray):Object {
        if (_discardingTooLongFrame) {
            var bytesToDiscard:Number = this._bytesToDiscard;
            const localBytesToDiscard:int = Math.min(bytesToDiscard, inBuf.bytesAvailable);
            inBuf.position += localBytesToDiscard;
            bytesToDiscard -= localBytesToDiscard;
            this._bytesToDiscard = bytesToDiscard;

            failIfNecessary(false);
        }

        if (inBuf.bytesAvailable < _lengthFieldEndOffset)
            return null;

        var actualLengthFieldOffset:int = inBuf.position + _lengthFieldOffset;
        var frameLength:Number = getUnadjustedFrameLength(inBuf, actualLengthFieldOffset, _lengthFieldLength, _byteOrder);

        if (frameLength < 0) {
            inBuf.position += _lengthFieldEndOffset;
            throw new IllegalOperationError("negative pre-adjustment length field: " + frameLength);
        }

        frameLength += _lengthAdjustment + _lengthFieldEndOffset;

        if (frameLength < _lengthFieldEndOffset) {
            inBuf.position += _lengthFieldEndOffset;
            throw new IllegalOperationError("Adjusted frame length (" + frameLength + ") is less " +
                    "than lengthFieldEndOffset: " + _lengthFieldEndOffset);
        }

        if (frameLength > _maxFrameLength) {
            var discard:Number = frameLength - inBuf.bytesAvailable;
            _tooLongFrameLength = frameLength;

            if (discard < 0) {
                // buffer contains more bytes than the frameLength so we can discard all now
                inBuf.position += frameLength;
            } else {
                // Enter the discard mode and discard everything received so far.
                _discardingTooLongFrame = true;
                _bytesToDiscard = discard;
                inBuf.position += inBuf.bytesAvailable;
            }

            failIfNecessary(true);
            return null;
        }

        // Never overflows because it's less than maxFrameLength
        var frameLengthInt:int = frameLength;
        if (inBuf.bytesAvailable < frameLengthInt) {
            return null;
        }

        if (_initialBytesToStrip > frameLengthInt) {
            inBuf.position += frameLengthInt;
            throw new IllegalOperationError("Adjusted frame length (" + frameLength + ") is less " +
                    "than initialBytesToStrip: " + _initialBytesToStrip);
        }

        inBuf.position += _initialBytesToStrip;

        // extract frame
        const readerIndex:int = inBuf.position;
        const actualFrameLength:int = frameLengthInt - _initialBytesToStrip;
        const frame:ByteArray = extractFrame(ctx, inBuf, readerIndex, actualFrameLength);
        inBuf.position += (readerIndex + actualFrameLength);

        return frame;
    }

    //noinspection JSMethodCanBeStatic
    protected function extractFrame(ctx:IChannelHandlerContext, inBuf:ByteArray, readerIndex:int, actualFrameLength:int):ByteArray {
        var bytes:ByteArray = new ByteArray();
        inBuf.readBytes(bytes, readerIndex, actualFrameLength);
        return bytes;
    }

    protected function getUnadjustedFrameLength(buf:ByteArray, offset:int, length:int, order:String):Number {
        buf.endian = order || _byteOrder;
        var frameLength:Number;
        var oldPos:int = buf.position;
        buf.position += offset;

        switch (length) {
            case 1:
                frameLength = buf.readUnsignedByte();
                break;
            case 2:
                frameLength = buf.readUnsignedShort();
                break;
            case 3:
            {
                if (order == Endian.BIG_ENDIAN) {
                    frameLength =
                            buf.readUnsignedByte() << 16 |
                            buf.readUnsignedByte() << 8 |
                            buf.readUnsignedByte();
                } else {
                    frameLength =
                            buf.readUnsignedByte() |
                            buf.readUnsignedByte() << 8 |
                            buf.readUnsignedByte() << 16;
                }
                break;
            }
            case 4:
                frameLength = buf.readUnsignedInt();
                break;
            case 8:
            {
                // TODO: read int64
                break;
            }
            default:
                throw new ArgumentError("Unsupported lengthFieldLength: " + _lengthFieldLength + " (expected: 1, 2, 3, 4, 8)");
        }

        buf.position = oldPos;

        return frameLength;
    }

    private function failIfNecessary(firstDetectionOfTooLongFrame:Boolean):void {
        if (_bytesToDiscard == 0) {
            // Reset to the initial state and tell the handlers that
            // the frame was too large.
            var tooLongFrameLength:Number = this._tooLongFrameLength;
            this._tooLongFrameLength = 0;
            this._discardingTooLongFrame = false;
            if (!_failFast || _failFast && firstDetectionOfTooLongFrame) {
                fail(tooLongFrameLength);
            }
        } else {
            // Keep discarding and notify handlers if necessary.
            if (_failFast && firstDetectionOfTooLongFrame) {
                fail(_tooLongFrameLength);
            }
        }
    }

    private function fail(frameLength:Number):void {
        if (frameLength > 0) {
            throw new IllegalOperationError("Adjusted frame length exceeds " + _maxFrameLength + ": " + frameLength + " - discarded");
        } else {
            throw new IllegalOperationError("Adjusted frame length exceeds " + _maxFrameLength + " - discarding");
        }
    }

}
}
