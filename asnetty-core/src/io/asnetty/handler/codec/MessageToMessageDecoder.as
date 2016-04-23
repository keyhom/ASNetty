package io.asnetty.handler.codec {

import io.asnetty.channel.ChannelInboundHandlerAdapter;
import io.asnetty.channel.IChannelHandlerContext;

/**
 * <code>ChannelInboundHandlerAdapter</code> which decodes from one message to
 * an other message.
 *
 * @author Jeremy
 */
public class MessageToMessageDecoder extends ChannelInboundHandlerAdapter {

    /** @private */
    private var _inboundMessageType:Class;

    /**
     * Creates a MessageToMessageEncoder instance.
     */
    public function MessageToMessageDecoder(inboundMessageType:Class) {
        super();
        if (!inboundMessageType)
            throw new ArgumentError("inboundMessageType non-null expected.");
        this._inboundMessageType = inboundMessageType;
    }

    /**
     * Returns <code>true</code> if the given message should be handled. If
     * <code>false</code> it will be passed to the next
     * <code>IChannelInboundHandler</code> in the <code>IChannelPipeline</code>.
     */
    public function acceptInboundMessage(msg:*):Boolean {
        return (msg is _inboundMessageType);
    }

    /**
     * @inheritDoc
     */
    override public function channelRead(ctx:IChannelHandlerContext, msg:*):void {
        const out:Vector.<Object> = new <Object>[];
        try {
            if (acceptInboundMessage(msg)) {
                decode(ctx, msg, out);
            } else {
                out.push(msg);
            }
        } finally {
            const size:int = out.length;
            for (var i:int = 0; i < size; i++) {
                ctx.fireChannelRead(out[i]);
            }

            out.splice(0, size); // clear
        }
    }

    /**
     * Decode from one messaeg to another. This method will be called for each
     * written message that can be handled.
     */
    protected function decode(ctx:IChannelHandlerContext, msg:*, out:Vector.<Object>):void {
        // NOOP.
    }

} // class MessageToMessageDecoder
}
