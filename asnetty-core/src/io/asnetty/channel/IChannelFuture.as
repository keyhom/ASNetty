package io.asnetty.channel {

import flash.events.IEventDispatcher;

[Event(name="operationComplete", type="io.asnetty.channel.ChannelFutureEvent")]
/**
 *
 * @author Jeremy
 */
public interface IChannelFuture extends IEventDispatcher {

    function get channel():IChannel;


}
}
