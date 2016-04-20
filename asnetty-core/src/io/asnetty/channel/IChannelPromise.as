package io.asnetty.channel {

/**
 * @author Jeremy
 */
public interface IChannelPromise extends IChannelFuture {

    function trySuccess():IChannelPromise;

    function tryFailure(cause:Error = null):IChannelPromise;

    function setSuccess():IChannelPromise;

    function setFailure(cause:Error = null):IChannelPromise;

}
}
