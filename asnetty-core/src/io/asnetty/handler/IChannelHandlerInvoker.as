package io.asnetty.handler
{
import flash.events.Event;

import io.asnetty.channel.IChannelPromise;

public interface IChannelHandlerInvoker
{

    function invokeChannelActive(ctx:IChannelHandlerContext):void;

    function invokeChannelInvative(ctx:IChannelHandlerContext):void;

    function invokeErrorCaught(ctx:IChannelHandlerContext, cause:Error):void;

    function invokeUserEventTriggered(ctx:IChannelHandlerContext,
            event:Event):void;

    function invokeChannelRead(ctx:IChannelHandlerContext, msg:*):void;

    function invokeChannelReadComplete(ctx:IChannelHandlerContext):void;

    function invokeChannelWritabilityChanged(ctx:IChannelHandlerContext):void;

    function invokeConnect(ctx:IChannelHandlerContext, host:String, port:uint,
            promise:IChannelPromise = null):void;

    function invokeClose(ctx:IChannelHandlerContext, promise:IChannelPromise =
            null):void;

    function invokeRead(ctx:IChannelHandlerContext):void;

    function invokeWrite(ctx:IChannelHandlerContext, msg:*,
            promise:IChannelPromise = null):void;

    function invokeFlush(ctx:IChannelHandlerContext):void;

}
}
