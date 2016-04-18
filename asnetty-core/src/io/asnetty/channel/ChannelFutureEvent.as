package io.asnetty.channel {

import flash.events.Event;

/**
 * @author Jeremy
 */
public class ChannelFutureEvent extends Event {

    static public const OPERATION_COMPLETE:String = "operationComplete";

    public function ChannelFutureEvent(eventType:String = OPERATION_COMPLETE,
            bubbles:Boolean = false, cancelable:Boolean = false) {
        super(eventType, bubbles, cancelable);
    }

    public function get future():IChannelFuture {
        return currentTarget as IChannelFuture;
    }

}
}
