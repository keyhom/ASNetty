package io.asnetty.channel {

/**
 * @author Jeremy
 */
public interface IUnsafe {

    function connect(host:String, port:int, promise:IChannelPromise):void;

    function disconnect(promise:IChannelPromise):void;

    function close(promise:IChannelPromise):void;

    function closeForcibly():void;

    function beginRead():void;

    function write(msg:*, promise:IChannelPromise):void;

    function flush():void;

    function get outboundBuffer():ChannelOutboundBuffer;

}
}
