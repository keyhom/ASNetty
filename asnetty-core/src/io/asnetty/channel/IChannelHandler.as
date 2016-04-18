package io.asnetty.channel {
/**
 * @author Jeremy
 */
public interface IChannelHandler {

    function handlerAdded(ctx:IChannelHandlerContext):void;

    function handlerRemoved(ctx:IChannelHandlerContext):void;

    function errorCaught(ctx:IChannelHandlerContext, cause:Error):void;

//    function channelActive(ctx:IChannelHandlerContext):void;
//
//    function channelInactive(ctx:IChannelHandlerContext):void;
//
//    function channelRead(ctx:IChannelHandlerContext, msg:*):void;
//
//    function channelReadComplete(ctx:IChannelHandlerContext):void;
//
//    function channelWritabilityChanged(ctx:IChannelHandlerContext):void;
//
//    function connect(ctx:IChannelHandlerContext, host:String, port:int, promise:IChannelPromise = null):void;
//
//    function disconnect(ctx:IChannelHandlerContext, promise:IChannelPromise = null):void;
//
//    function close(ctx:IChannelHandlerContext, promise:IChannelPromise = null):void;
//
//    function read(ctx:IChannelHandlerContext):void;
//
//    function write(ctx:IChannelHandlerContext, msg:*, promise:IChannelPromise = null):void;
//
//    function flush(ctx:IChannelHandlerContext):void;

}
}
