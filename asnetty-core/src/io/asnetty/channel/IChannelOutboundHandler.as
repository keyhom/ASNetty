package io.asnetty.channel {

/**
 * @author Jeremy
 */
public interface IChannelOutboundHandler extends IChannelHandler {

    function connect(ctx:IChannelHandlerContext, host:String, port:int, promise:IChannelPromise = null):void;

    function disconnect(ctx:IChannelHandlerContext, promise:IChannelPromise = null):void;

    function close(ctx:IChannelHandlerContext, promise:IChannelPromise = null):void;

    function read(ctx:IChannelHandlerContext):void;

    function write(ctx:IChannelHandlerContext, msg:*, promise:IChannelPromise = null):void;

    function flush(ctx:IChannelHandlerContext):void;

}
}
