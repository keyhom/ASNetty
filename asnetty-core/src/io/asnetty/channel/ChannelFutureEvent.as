package io.asnetty.channel {

import flash.events.Event;

/**
 * @author Jeremy
 */
public class ChannelFutureEvent extends Event {

    static public const OPERATION_COMPLETE:String = "operationComplete";

    public var data:*;

    public function ChannelFutureEvent(data:*, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(OPERATION_COMPLETE, bubbles, cancelable);
        this.data = data;
    }

    public function get future():IChannelFuture {
        return currentTarget as IChannelFuture;
    }

}
}
