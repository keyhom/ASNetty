package io.asnetty.channel {

/**
 * @author Jeremy
 */
public interface IChannelPromise extends IChannelFuture {

    function setSuccess():IChannelPromise;

    function setFailure(cause:Error = null):IChannelPromise;

}
}
