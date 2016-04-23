package io.asnetty.handler.codec {

import flash.utils.ByteArray;

import io.asnetty.channel.IChannelHandlerContext;

/**
 * A decoder that splits the received <code>ByteArray</code>s on line encodings.
 * <p>
 * Both <code>"\n"</code> and <code>"\r\n"</code> are handled.
 * For a more general delimiter-based decoder, see @link
 * DelimiterBasedFrameDecoder.
 * </p>
 *
 * @author Jeremy
 */
public class LineBasedFrameDecoder extends ByteToMessageDecoder {

    private var _maxLength:int;
    private var _failFast:Boolean;
    private var _stripDelimiter:Boolean;
    private var _discarding:Boolean;
    private var _discardedBytes:int;

    public function LineBasedFrameDecoder(maxLength:int, stripDelimiter:Boolean
            = true, failFast:Boolean = false) {
        super();
        this._maxLength = maxLength;
        this._stripDelimiter = stripDelimiter;
        this._failFast = failFast;
    }

    /**
     * @inheritDoc
     */
    override final protected function decode(ctx:IChannelHandlerContext, bufIn:ByteArray,
                                             out:Vector.<Object>):void {
        var decoded:Object = doDecode(ctx, bufIn);
        if (decoded) {
            out.push(decoded);
        }
    }

    protected function doDecode(ctx:IChannelHandlerContext,
                                buffer:ByteArray):Object {
        const eol:int = findEndOfLine(buffer);
        var length:int;
        var delimLength:int = 1;
        var oldPos:int;

        if (!_discarding) {
            if (eol >= 0) {
                length = eol - buffer.position;

                var frame:ByteArray;
                oldPos = buffer.position;
                buffer.position = eol;
                delimLength = buffer.readByte() == int('\r') ? 2 : 1;
                buffer.position = oldPos;

                if (length > _maxLength) {
                    buffer.position = eol + delimLength;
                    fail(ctx, length.toString());
                    return null;
                }

                if (_stripDelimiter) {
                    frame = new ByteArray;
                    buffer.readBytes(frame, eol, length);
                    buffer.position += delimLength;
                } else {
                    frame = new ByteArray;
                    buffer.readBytes(frame, eol, length + delimLength);
                }

                return frame;
            } else {
                length = buffer.bytesAvailable;
                if (length > _maxLength) {
                    _discardedBytes = length;
                    _discarding = true;
                    if (_failFast)
                        fail(ctx, "over " + _discardedBytes);
                }
                return null;
            }
        } else {
            if (eol >= 0) {
                length = _discardedBytes + eol - buffer.position;
                oldPos = buffer.position;
                buffer.position = eol;
                delimLength = buffer.readByte() == int('\r') ? 2 : 1;
                buffer.position = oldPos;
                buffer.position = eol + delimLength;
                _discardedBytes = 0;
                _discarding = false;
                if (!_failFast)
                    fail(ctx, length.toString());
            } else {
                _discardedBytes += buffer.bytesAvailable;
            }
        }
        return null;
    }

    private function fail(ctx:IChannelHandlerContext, length:String):void {
        ctx.fireErrorCaught(new Error("frame length (" + length + ") exceeds the"
                + " allowed maximum (" + _maxLength + ")"));
    }

    private static function findEndOfLine(buffer:ByteArray):int {
        // for each find the LF.
        var i:int = buffer.position;
        var l:int = buffer.bytesAvailable;
        var oldPos:int = buffer.position;

        try {
            for (; i < l;) {
                const c:int = buffer.readByte();
                if (c == int('\n'))
                    break;
                i++;
            }

            if (i > oldPos) {
                buffer.position = i - 1;
                if (buffer.readByte() == int('\r'))
                    i = i - 1;
            }

        } finally {
            buffer.position = oldPos;
        }

        if (i >= l)
            return -1;

        return i;
    }

} // class LineBasedFrameDecoder
}
