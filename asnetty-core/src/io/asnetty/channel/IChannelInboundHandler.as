package io.asnetty.channel {

/**
 * @author Jeremy
 */
public interface IChannelInboundHandler extends IChannelHandler {

    function channelActive(ctx:IChannelHandlerContext):void;

    function channelInactive(ctx:IChannelHandlerContext):void;

    function channelRead(ctx:IChannelHandlerContext, msg:*):void;

    function channelReadComplete(ctx:IChannelHandlerContext):void;

    function channelWritabilityChanged(ctx:IChannelHandlerContext):void;

}
}
