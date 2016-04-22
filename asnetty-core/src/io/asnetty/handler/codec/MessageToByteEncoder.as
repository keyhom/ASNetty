package io.asnetty.handler.codec {

import flash.utils.ByteArray;

import io.asnetty.channel.ChannelOutboundHandlerAdapter;
import io.asnetty.channel.IChannelHandlerContext;
import io.asnetty.channel.IChannelPromise;

/**
 * <code>ChannelOutboundHandlerAdapter</code> which encodes message in a
 * stream-like fashion from one message to an <code>ByteArray</code>.
 *
 * @author Jeremy
 */
public class MessageToByteEncoder extends ChannelOutboundHandlerAdapter {

    /** @private */
    private static const EMPTY_BUF:ByteArray = new ByteArray;

    /** @private */
    private var _outboundMessageType:Class;

    /**
     * Creates a new MessageToByteEncoder instance.
     */
    public function MessageToByteEncoder(outboundMessageType:Class) {
        super();
        if (null == outboundMessageType)
            throw new ArgumentError("outboundMessageType can not be null.");
        this._outboundMessageType = outboundMessageType;
    }

    /**
     * Returns <code>true</code> if the given message should be handled. If
     * <code>false</code> it will be passed to the next
     * <code>ChannelOutboundHandler</code> in the <code>ChannelPipeline</code>.
     */
    public function acceptOutboundMessage(msg:*):Boolean {
        return (msg is _outboundMessageType);
    }

    override public function write(ctx:IChannelHandlerContext, msg:*,
                                   promise:IChannelPromise = null):void {
        var buf:ByteArray = null;
        try {
            if (acceptOutboundMessage(msg)) {
                buf = allocateBuffer(ctx, msg);

                // Encode do.
                encode(ctx, msg, buf);

                if (buf.bytesAvailable > 0) {
                    ctx.makeWrite(buf, promise);
                } else {
                    buf.clear();
                    ctx.makeWrite(EMPTY_BUF, promise);
                }

                buf = null;
            } else {
                ctx.makeWrite(msg, promise);
            }
        } catch (e:Error) {
            throw e;
        } finally {
            if (buf) buf.clear();
        }
    }

    //noinspection JSMethodCanBeStatic
    /**
     * Allocates a <code>ByteArray</code> which will be used as argument of
     * <code>#encode(IChannelHandlerContext, msg, ByteArray)</code>. Sub-classes
     * may override this method to return a <code>ByteArray</code> with a
     * perfect matching <code>initialCapacity</code>.
     */
    protected function allocateBuffer(ctx:IChannelHandlerContext, msg:*,
                                      options:Object = null):ByteArray {
        return new ByteArray;
    }

    /**
     * Encode a message into a <code>ByteArray</code>. This method will be
     * called for each written message that can be handled by this encoder.
     */
    protected function encode(ctx:IChannelHandlerContext, msg:*,
                              buf:ByteArray):void {
        // NOOP.
    }

}
}
