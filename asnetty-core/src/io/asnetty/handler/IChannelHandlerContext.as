package io.asnetty.handler {
import io.asnetty.channel.IChannel;
import io.asnetty.channel.IChannelFuture;
import io.asnetty.channel.IChannelPipeline;
import io.asnetty.channel.IChannelPromise;

public interface IChannelHandlerContext {

    function get handler():IChannelHandler;

    function get channel():IChannel;

    function get isRemoved():Boolean;

    function get pipeline():IChannelPipeline;

    function fireChannelActive():IChannelHandlerContext;

    function fireChannelInactive():IChannelHandlerContext;

    function fireErrorCaught(cause:Error):IChannelHandlerContext;

    function fireChannelRead(msg:*):IChannelHandlerContext;

    function fireChannelReadComplete():IChannelHandlerContext;

    function fireChannelWritabilityChanged():IChannelHandlerContext;

    function makeConnect(host:String, port:int, promise:IChannelPromise = null):IChannelFuture;

    function makeDisconnect(promise:IChannelPromise = null):IChannelFuture;

    function makeClose(promise:IChannelPromise = null):IChannelFuture;

    function makeRead():IChannelHandlerContext;

    function makeWrite(obj:*, promise:IChannelPromise = null):IChannelFuture;

    function makeFlush():IChannelHandlerContext;

    function makeWriteAndFlush(msg:*, promise:IChannelPromise = null):IChannelFuture;

}
}
