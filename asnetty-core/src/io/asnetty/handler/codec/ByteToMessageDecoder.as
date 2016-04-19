package io.asnetty.handler.codec {

import flash.utils.ByteArray;

import io.asnetty.channel.ChannelInboundHandlerAdapter;
import io.asnetty.channel.IChannelHandlerContext;

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

    override public function handlerAdded(ctx:IChannelHandlerContext):void {
        // TODO: initialization.
    }

    override public function handlerRemoved(ctx:IChannelHandlerContext):void {
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
            ctx.makeRead();
        ctx.fireChannelReadComplete();
    }

    protected virtual function decode(ctx:IChannelHandlerContext,
                                      raw:ByteArray, out:Vector.<Object>):void {

    }

} // class ByteToMessageDecoder
}
