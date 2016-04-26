package io.asnetty.handler.codec {

import flash.errors.IllegalOperationError;
import flash.utils.ByteArray;
import flash.utils.Endian;

import io.asnetty.channel.IChannelHandlerContext;

/**
 * An encoder that prepends the length of the message. The length value is
 * prepended as a binary form.
 *
 * @author Jeremy
 */
public class LengthFieldPrepender extends MessageToMessageEncoder {

    private var _byteOrder:String;
    private var _lengthFieldLength:int;
    private var _lengthAdjustment:int;
    private var _lengthIncludesLengthFieldLength:Boolean;

    /**
     * Creates a LengthFieldPrepender instance.
     */
    public function LengthFieldPrepender(lengthFieldLength:int,
                                         lengthAdjustment:int = 0,
                                         lengthIncludesLengthFieldLength:Boolean
                                                 = false, byteOrder:String =
                                                 Endian.BIG_ENDIAN) {
        super(ByteArray);
        if (lengthFieldLength != 1 && lengthFieldLength != 2 &&
                lengthFieldLength != 3 && lengthFieldLength != 4 &&
                lengthFieldLength != 8) {
            throw new ArgumentError("lengthFieldLength must be either 1, 2, 3,"
                    + " 4, or 8: " + lengthFieldLength);
        }
        _byteOrder = byteOrder || Endian.BIG_ENDIAN;

        this._byteOrder = byteOrder;
        this._lengthFieldLength = lengthFieldLength;
        this._lengthIncludesLengthFieldLength = lengthIncludesLengthFieldLength;
        this._lengthAdjustment = lengthAdjustment;
    }

    override protected function encode(ctx:IChannelHandlerContext, msg:*,
                                       out:Vector.<Object>):void {
        // msg is ByteArray.
        var buf:ByteArray = msg as ByteArray;
        if (!buf)
            return; // throw instead of return ?

        var length:int = buf.bytesAvailable + _lengthAdjustment;
        if (_lengthIncludesLengthFieldLength) {
            length += _lengthFieldLength;
        }

        if (length < 0)
            throw new ArgumentError("Adjusted frame length (" + length + ") is "
                    + "less than zero.");

        var buffer:ByteArray;

        switch (_lengthFieldLength) {
            case 1:
                if (length >= 256) {
                    throw new ArgumentError("length does not fit into a byte: "
                            + length);
                }
                buffer = allocateBuffer(1, _byteOrder);
                buffer.writeByte(length);
                break;
            case 2:
                if (length >= 65536) {
                    throw new ArgumentError("length does not fit into a short" +
                            " integer: " + length);
                }
                buffer = allocateBuffer(2, _byteOrder);
                buffer.writeShort(length);
                break;
            case 3:
                buffer = allocateBuffer(3, _byteOrder);
                if (_byteOrder == Endian.BIG_ENDIAN) {
                    buffer.writeByte(length >> 16);
                    buffer.writeByte(length >> 8);
                    buffer.writeByte(length);
                } else {
                    buffer.writeByte(length);
                    buffer.writeByte(length >> 8);
                    buffer.writeByte(length >> 16);
                }
                break;
            case 4:
                buffer = allocateBuffer(4, _byteOrder);
                buffer.writeInt(length);
                break;
            case 8:
            // buffer = allocateBuffer(8);
            // FIXME: write int64
            // break;
            default:
                throw new IllegalOperationError("should be reach here.");
        }

        if (buffer) {
            buffer.position = 0;
            out.push(buffer);
        }

        out.push(msg);
    }

    //noinspection JSMethodCanBeStatic
    protected function allocateBuffer(capacity:Number = NaN, byteOrder:String =
            Endian.BIG_ENDIAN):ByteArray {
        var bs:ByteArray = new ByteArray;
        bs.endian = byteOrder;

        if (!isNaN(capacity) && capacity > 0) {
            bs.length = capacity;
        }
        return bs;
    }

}
}
