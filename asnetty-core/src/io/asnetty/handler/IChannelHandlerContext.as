package io.asnetty.handler {
import io.asnetty.channel.IChannel;
import io.asnetty.channel.IChannelFuture;
import io.asnetty.channel.IChannelPipeline;
import io.asnetty.channel.IChannelPromise;

public interface IChannelHandlerContext {

    function get channel():IChannel;

    function get invoker():IChannelHandlerInvoker;

    function get isRemoved():Boolean;

    function get pipeline():IChannelPipeline;

    function fireChannelActive():IChannelHandlerContext;

    function fireChannelInactive():IChannelHandlerContext;

    function fireErrorCaught(cause:Error):IChannelHandlerContext;

    function fireChannelRead(msg:*):IChannelHandlerContext;

    function fireChannelReadComplete():IChannelHandlerContext;

    function fireChannelWritabilityChanged():IChannelHandlerContext;

    function connect(host:String, port:int, promise:IChannelPromise = null):IChannelFuture;

    function disconnect(promise:IChannelPromise = null):IChannelFuture;

    function close(promise:IChannelPromise = null):IChannelFuture;

    function read():IChannelHandlerContext;

    function write(obj:*, promise:IChannelPromise = null):IChannelHandlerContext;

    function flush():IChannelHandlerContext;

    function writeAndFlush(msg:*, promise:IChannelPromise = null):IChannelFuture;

}
}
