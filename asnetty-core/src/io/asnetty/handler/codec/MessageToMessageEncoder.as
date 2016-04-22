package io.asnetty.handler.codec {

import avmplus.getQualifiedClassName;

import flash.errors.IllegalOperationError;

import io.asnetty.channel.ChannelOutboundHandlerAdapter;
import io.asnetty.channel.IChannelHandlerContext;
import io.asnetty.channel.IChannelPromise;

/**
 *
 *
 * @author Jeremy
 */
public class MessageToMessageEncoder extends ChannelOutboundHandlerAdapter {

    private var _outboundMessageType:Class;

    /**
     * Creates a MessageToMessageEncoder instance.
     */
    public function MessageToMessageEncoder(outboundMessageType:Class) {
        super();
        this._outboundMessageType = outboundMessageType;
    }

    /**
     * Returns <code>true</code> if the given message should be handled. If
     * <code>false</code> it will be passed to the next
     * <code>IChannelOutboundHandler</code> in the
     * <code>IChannelPipeline</code>.
     */
    public function acceptOutboundMessage(msg:*):Boolean {
        return (msg is _outboundMessageType);
    }

    /**
     * {@inheritDoc}
     */
    override public function write(ctx:IChannelHandlerContext, msg:*,
            promise:IChannelPromise = null):void {
        var out:Vector.<Object> = null;

        try {
            if (acceptOutboundMessage(msg)) {
                out = new <Object>[];

                // encode
                encode(ctx, msg, out);

                if (out.length == 0) {
                    out = null;

                    throw new IllegalOperationError(getQualifiedClassName(this)
                            + " must produce at least one message.");
                }
            } else {
                ctx.makeWrite(msg, promise);
            }
        } finally {
            if (out) {
                const sizeMinusOne:int = out.length - 1;
                if (sizeMinusOne == 0) {
                    ctx.makeWrite(out[0], promise);
                } else if (sizeMinusOne > 0) {
                    // check if we can use a voidPromise for our extra writes to
                    // reduce GC-Pressure.
                    for (var i:int = 0;i < sizeMinusOne; ++i) {
                        ctx.makeWrite(out[i]);
                    }
                    ctx.makeWrite(out[sizeMinusOne], promise);
                }
                // clear out list.
                out.splice(0, out.length);
                out = null;
            }
        }
    }

    /**
     * Encode from one message to another. This method will be called for each
     * written message that can be handled by this encoder.
     */
    protected function encode(ctx:IChannelHandlerContext, msg:*,
            out:Vector.<Object>):void {
        // NOOP.
    }

}
}
