package io.asnetty.channel {

import flash.utils.Dictionary;

import io.asnetty.handler.IChannelHandler;
import io.asnetty.handler.IChannelHandlerContext;

/**
 * @author Jeremy
 */
public interface IChannelPipeline {

    function addFirst(name:String, handler:IChannelHandler):IChannelPipeline;

    function addLast(name:String, handler:IChannelHandler):IChannelPipeline;

    function addBefore(baseName:String, name:String, handler:IChannelHandler):IChannelPipeline;

    function addAfter(baseName:String, name:String, handler:IChannelHandler):IChannelPipeline;

    function remove(handler:IChannelHandler):IChannelHandler;

    function removeByName(name:String):IChannelHandler;

    function removeByType(clazz:Class):Vector.<IChannelHandler>;

    function removeFirst():IChannelHandler;

    function removeLast():IChannelHandler;

    function replace(old:*, newName:String,
                     newHandler:IChannelHandler):IChannelPipeline;

    /** Returns the <code>IChannel</code> that this pipeline attached to. */
    function get channel():IChannel;

    function get first():IChannelHandler;

    function get last():IChannelHandler;

    function get firstContext():IChannelHandlerContext;

    function get lastContext():IChannelHandlerContext;

    function get names():Vector.<String>;

    function toMap():Dictionary;

    /**
     * Retrieves the target <code>IChannelHandler</code> by the specified
     * <code>byWhat</code> parameter, it can be a name, or a class type.
     */
    function getHandler(byWhat:*):IChannelHandler;

    /**
     * Returns the context object of the specified <code>nameOrInstanceOrClass</code>
     * in this pipeline.
     */
    function context(nameOrInstanceOrClass:*):IChannelHandlerContext;

    function fireChannelActive():IChannelPipeline;

    function fireChannelInactive():IChannelPipeline;

    function fireErrorCaught(cause:Error):IChannelPipeline;

//    function fireUserEventTriggered(event:Event):IChannelPipeline;
    function fireChannelRead(msg:Object):IChannelPipeline;

    function fireChannelReadComplete():IChannelPipeline;

    function fireChannelWritabilityChanged():IChannelPipeline;

    function connect(host:String, port:uint, promise:IChannelPromise = null):IChannelFuture;

    function disconnect(promise:IChannelPromise = null):IChannelFuture;

    function close(promise:IChannelPromise = null):IChannelFuture;

    function read():IChannelPipeline;

    function write(msg:*, promise:IChannelPromise = null):IChannelPipeline;

    function flush():IChannelPipeline;

    function writeAndFlush(msg:*, promise:IChannelPromise =
            null):IChannelFuture;

} // interface IChannelPipeline
}
