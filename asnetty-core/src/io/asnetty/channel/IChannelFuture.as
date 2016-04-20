package io.asnetty.channel {

import flash.events.IEventDispatcher;

[Event(name="operationComplete", type="io.asnetty.channel.ChannelFutureEvent")]
/**
 *
 * @author Jeremy
 */
public interface IChannelFuture extends IEventDispatcher {

    /**
     * Returns a channel where the I/O operation associated with this future takes place.
     */
    function get channel():IChannel;

    /**
     * Returns <code>true</code> if the task completed.
     */
    function get isDone():Boolean;

    /**
     * Returns <code>true</code> if the task was cancelled before it completed normally.
     */
    function get isCancelled():Boolean;

    /**
     * Returns <code>true</code> if and only if the task was completed successfully.
     */
    function get isSuccess():Boolean;

    /**
     * Returns the cause of the failed I/O operation if the task was failed.
     */
    function get cause():Error;

    /**
     * Returns <code>true</code> if and only this task can be cancelled via <code>#cancel()</code>.
     */
    function get isCancellable():Boolean;

    /**
     * Cancels this task.
     */
    function cancel():Boolean;

    /**
     * Return the result. If the future is not done yet this will return null.
     */
    function getNow():*;

} // interface IChannelFuture
}
