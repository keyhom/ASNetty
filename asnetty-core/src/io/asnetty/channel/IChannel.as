package io.asnetty.channel {

/**
 * @author Jeremy
 */
public interface IChannel {

    /** Returns the globally unique identifier of this {@link IChannel} */
    function get id():uint;

    /** Return the parent of this channel. */
    function get parent():IChannel;

    function get unsafe():IUnsafe;

    function get isOpen():Boolean;

    function get isActive():Boolean;

    function get isWritable():Boolean;

    function get isReadable():Boolean;

    function get pipeline():IChannelPipeline;

    function connect(host:String, port:int, timeout:Number = 30):IChannelFuture;

    function disconnect(promise:IChannelPromise = null):IChannelFuture;

    function close(promise:IChannelPromise = null):IChannelFuture;

    function read():IChannel;

    function write(msg:*, promise:IChannelPromise = null):IChannelFuture;

    function flush():IChannel;

    function writeAndFlush(msg:*, promise:IChannelPromise = null):IChannelFuture;

}
}
