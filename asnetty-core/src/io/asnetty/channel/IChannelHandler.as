package io.asnetty.channel {

/**
 * @author Jeremy
 */
public interface IChannelHandler {

    function handlerAdded(ctx:IChannelHandlerContext):void;

    function handlerRemoved(ctx:IChannelHandlerContext):void;

    function errorCaught(ctx:IChannelHandlerContext, cause:Error):void;

}
}
