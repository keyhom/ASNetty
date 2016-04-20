package io.asnetty.channel {

import flash.errors.IllegalOperationError;
import flash.events.EventDispatcher;

/**
 * @author Jeremy
 */
public class DefaultChannelPromise extends EventDispatcher implements IChannelPromise {

    private static const UNCANCELLABLE:String = "__DefaultChannelPromise#UNCANCELLABLE__";
    private static const CANCELLATION:String = "__DefaultChannelPromise#CANCELLATION__";

    private var _channel:IChannel;
    private var _result:*;

    public function DefaultChannelPromise(channel:IChannel) {
        super();
        this._channel = channel;
    }

    public function trySuccess():IChannelPromise {
        try {
            this.setSuccess();
        } catch (e:Error) {
            // NOOP
        }
        return this;
    }

    public function tryFailure(e:Error = null):IChannelPromise {
        try {
            this.setFailure(e);
        } catch (e:Error) {
            // NOOP
        }
        return this;
    }

    public function setSuccess():IChannelPromise {
        if (isDone)
            throw new IllegalOperationError("setSuccess");

        _result = _channel;
        dispatchEvent(new ChannelFutureEvent);
        return this;
    }

    public function setFailure(cause:Error = null):IChannelPromise {
        if (isDone)
            throw new IllegalOperationError("setFailure");

        _result = cause || new Error("setFailure");
        dispatchEvent(new ChannelFutureEvent);
        return this;
    }

    public function get channel():IChannel {
        return _channel;
    }

    public function get isCancelled():Boolean {
        return _result == CANCELLATION;
    }

    public function get isDone():Boolean {
        return isDone0(_result);
    }

    public function get isSuccess():Boolean {
        if (null == _result || UNCANCELLABLE == _result)
            return false;
        return !(_result is Error);
    }

    public function get cause():Error {
        return _result as Error;
    }

    public function get isCancellable():Boolean {
        return _result == null;
    }

    public function cancel():Boolean {
        var result:* = this._result;
        if (isDone0(result) || result == UNCANCELLABLE) {
            return false;
        }

        try {
            // allow only once.
            this._result = CANCELLATION;
        } finally {
            // notify all listeners.
            dispatchEvent(new ChannelFutureEvent());
        }
        return true;
    }

    private static function isDone0(result:*):Boolean {
        return result != null && result != UNCANCELLABLE;
    }

    public function getNow():* {
        return _result;
    }

}
}
