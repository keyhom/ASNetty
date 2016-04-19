package io.asnetty.handler.codec {

import io.asnetty.channel.ChannelInboundHandlerAdapter;

/**
 *
 * @author Jeremy
 */
public class ByteToMessageDecoder extends ChannelInboundHandlerAdapter {

    /** @private */
    private var _cumulation:ByteArray;

    public function ByteToMessageDecoder() {
        super();
    }

    override public function handlerAdded():void {
        // TODO: initialization.
    }

    override public function handlerRemoved():void {
        // TODO: free up.
    }

    override public function channelRead(ctx:IChannelHandlerContext, msg:*):void {
        // TODO: combine bytes.
        // TODO: fire decode.
    }

    override public function channelReadComplete(ctx:IChannelHandlerContext):void {
        // TODO: mark or reset read flags.
        // TODO: handle decode states.
        if (!ctx.channel.config.autoRead)
            ctx.read();
        ctx.fireChannelReadComplete();
    }

    protected virtual function decode(ctx:IChannelHandlerContext,
            raw:ByteArray, out:Vector.<Object>);

} // class ByteToMessageDecoder
}
