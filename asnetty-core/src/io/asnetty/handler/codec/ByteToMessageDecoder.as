package io.asnetty.handler.codec {

import avmplus.getQualifiedClassName;

import flash.errors.IllegalOperationError;
import flash.utils.ByteArray;

import io.asnetty.channel.ChannelInboundHandlerAdapter;
import io.asnetty.channel.IChannelHandlerContext;

/**
 *
 * @author Jeremy
 */
public class ByteToMessageDecoder extends ChannelInboundHandlerAdapter {

    /** @private */
    private static const EMPTY_BUF:ByteArray = new ByteArray;

    /**
     * Cumulate <code>ByteArray</code>s by merge them into one
     * <code>ByteArray</code>'s, using memory copies.
     */
    public static function MERGE_CUMULATE(cumulation:ByteArray,
                                          bufIn:ByteArray):ByteArray {
        var oldPos : int = cumulation.position;
        cumulation.position = cumulation.length;

        cumulation.writeBytes( bufIn );
        cumulation.position = oldPos;
        bufIn.clear();

        return cumulation;
    }

    private var _cumulation:ByteArray;
    private var _cumulator:Function = MERGE_CUMULATE;

    private var _singleDecode:Boolean;
    private var _decodeWasNull:Boolean;
    private var _first:Boolean;
    private var _discardAfterReads:int = 16;
    private var _numReads:int;

    public function ByteToMessageDecoder() {
        super();
    }

    public function get singleDecode():Boolean {
        return _singleDecode;
    }

    public function set singleDecode(value:Boolean):void {
        _singleDecode = value;
    }

    public function get cumulator():Function {
        return _cumulator;
    }

    public function set cumulator(value:Function):void {
        _cumulator = value;
    }

    public function get discardAfterReads():int {
        return _discardAfterReads;
    }

    public function set discardAfterReads(value:int):void {
        _discardAfterReads = value;
    }

    protected function get actualReadableBytes():int {
        return internalBuf.bytesAvailable;
    }

    protected function get internalBuf():ByteArray {
        return _cumulation ? _cumulation : EMPTY_BUF;
    }

    override public final function handlerRemoved(ctx:IChannelHandlerContext):void {
        // TODO: free up.
        const buf:ByteArray = this.internalBuf;
        const readable:int = buf.bytesAvailable;
        if (readable > 0) {
            const bytes:ByteArray = new ByteArray;
            buf.readBytes(bytes, 0, readable);
            buf.clear();
            ctx.fireChannelRead(bytes);
        } else {
            buf.clear();
        }

        _cumulation = null;
        _numReads = 0;

        ctx.fireChannelReadComplete();

        onHandlerRemoved(ctx);
    }

    /**
     * Gets called after the <code>ByteToMessageDecoder</code> was removed from
     * the actual context and it doesn't handle events anymore.
     */
    protected function onHandlerRemoved(ctx:IChannelHandlerContext):void {
        // NOOP.
    }

    override public function channelRead(ctx:IChannelHandlerContext, msg:*):void {
        if (msg is ByteArray) {
            const out:Vector.<Object> = new <Object>[];
            try {
                const data:ByteArray = msg as ByteArray;
                _first = _cumulation == null;
                if (_first) {
                    _cumulation = data;
                } else {
                    _cumulation = cumulator(_cumulation, data);
                }

                callDecode(ctx, _cumulation, out);
            } finally {
                if (_cumulation && !_cumulation.bytesAvailable) {
                    _numReads = 0;
                    _cumulation.clear();
                    _cumulation = null;
                } else if (++_numReads >= _discardAfterReads) {
                    // We did enough reads already try to discard some bytes wo
                    // we not risk to see a OOME.
                    _numReads = 0;
                    discardSomeReadBytes();
                }

                const size:int = out.length;
                _decodeWasNull = size == 0;
                fireChannelRead(ctx, out, size);

                out.splice(0, size);
            }
        } else {
            ctx.fireChannelRead(msg);
        }
    }

    override public function channelReadComplete(ctx:IChannelHandlerContext):void {
        _numReads = 0;
        // discardSomeReadBytes();
        if (_decodeWasNull) {
            _decodeWasNull = false;
            if (!ctx.channel.config.autoRead) {
                ctx.makeRead();
            }
        }
        ctx.fireChannelReadComplete();
    }

    override public function channelInactive(ctx:IChannelHandlerContext):void {
        channelInputClosed(ctx, true);
    }

    protected final function discardSomeReadBytes():void {
        if (_cumulation && !_first) {
            // XXX: discardSomeReadBytes.
        }
    }

    protected function channelInputClosed(ctx:IChannelHandlerContext,
                                          callChannelInactive:Boolean):void {
        const out:Vector.<Object> = new <Object>[];
        try {
            if (_cumulation) {
                callDecode(ctx, _cumulation, out);
                decodeLast(ctx, _cumulation, out);
            } else {
                decodeLast(ctx, EMPTY_BUF, out);
            }
        } catch (e:Error) {
            throw e;
        } finally {
            try {
                if (_cumulation) {
                    _cumulation.clear();
                    _cumulation = null;
                }

                const size:int = out.length;
                fireChannelRead(ctx, out, size);
                if (size > 0) {
                    // something was read, call fireChannelReadComplete()
                    ctx.fireChannelReadComplete();
                }
                if (callChannelInactive) {
                    ctx.fireChannelInactive();
                }
            } finally {
                // recycle in all cases.
                // out.recycle();
            }
        }
    }

    /**
     * Called once data should be decoded from the given <code>ByteBuf</code>. This method will call
     * <code>#decode(IChannelHandlerContext, ByteArray, Vector.<Object>)</code> as long as decoding should
     * take place.
     */
    protected function callDecode(ctx:IChannelHandlerContext, bufIn:ByteArray,
                                  out:Vector.<Object>):void {
        while (bufIn.bytesAvailable > 0) {
            var outSize:int = out.length;

            if (outSize > 0) {
                fireChannelRead(ctx, out, outSize);
                out.splice(0, out.length); // clear

                // Check if this handler was removed before continuing with decoding.
                // If it was removed, it's not safe to continue to operate on the buffer.

                if (ctx.isRemoved) {
                    break;
                }
                outSize = 0;
            }

            var oldInputLength:int = bufIn.bytesAvailable;
            decode(ctx, bufIn, out);

            // Check if this handler was removed before continuing the loop.
            // If it's removed, it's not safe to continue to operate on the buffer.
            if (ctx.isRemoved)
                break;

            if (outSize == out.length) {
                if (oldInputLength == bufIn.bytesAvailable)
                    break;
                else
                    continue;
            }

            if (oldInputLength == bufIn.bytesAvailable) {
                throw new IllegalOperationError(getQualifiedClassName(this) + ".decode() did not read " +
                        "anything but decoded a message.");
            }

            if (singleDecode)
                break;
        }
    }

    protected function decode(ctx:IChannelHandlerContext, bufIn:ByteArray,
                              out:Vector.<Object>):void {

    }

    protected function decodeLast(ctx:IChannelHandlerContext, bufIn:ByteArray,
                                  out:Vector.<Object>):void {

    }

    internal static function expandCumulation(cumulation:ByteArray,
                                              readable:int):ByteArray {
        // NOOP.
        return cumulation;
    }

    internal static function fireChannelRead(ctx:IChannelHandlerContext, msgs:Vector.<Object>,
                                             numElements:int):void {
        for (var i:int = 0; i < numElements; ++i) {
            ctx.fireChannelRead(msgs[i]);
        }
    }

} // class ByteToMessageDecoder
}
