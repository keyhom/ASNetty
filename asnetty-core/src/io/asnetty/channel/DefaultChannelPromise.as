package io.asnetty.channel {

import flash.events.EventDispatcher;

/**
 * @author Jeremy
 */
public class DefaultChannelPromise extends EventDispatcher implements IChannelPromise {

    private var _channel:IChannel;

    public function DefaultChannelPromise(channel:IChannel) {
        super();
        this._channel = channel;
    }

    public function trySuccess():void {
        try {
            this.setSuccess();
        } catch (e:Error) {
            // NOOP
        }
    }

    public function tryFailure(e:Error = null):void {
        try {
            this.setFailure(e);
        } catch (e:Error) {
            // NOOP
        }
    }

    public function setSuccess():IChannelPromise {
        dispatchEvent(new ChannelFutureEvent);
        return this;
    }

    public function setFailure(cause:Error = null):IChannelPromise {
        cause = cause || new Error("setFailure");
        // TODO: Error caught handle.
        dispatchEvent(new ChannelFutureEvent);
        return this;
    }

    public function get channel():IChannel {
        return _channel;
    }

}
}
