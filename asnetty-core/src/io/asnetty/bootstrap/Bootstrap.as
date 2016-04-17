//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package io.asnetty.bootstrap {

import avmplus.getQualifiedClassName;

import flash.events.EventDispatcher;

import io.asnetty.channel.ChannelFutureEvent;
import io.asnetty.channel.IChannel;
import io.asnetty.channel.IChannelFuture;
import io.asnetty.channel.IChannelPipeline;
import io.asnetty.handler.IChannelHandler;

[Event(name="complete", type="flash.events.Event")]
/**
 *
 * @author Jeremy
 */
public class Bootstrap extends EventDispatcher {

    private var _channelClass:Class;
    private var _options:Object;
    private var _handler:IChannelHandler;

    public function channel(channelClass:Class):Bootstrap {
        this._channelClass = channelClass;
        return this;
    }

    public function option(key:String, value:*):Bootstrap {
        this._options = this._options || {};
        this._options[key] = value;
        return this;
    }

    public function handler(handler:IChannelHandler):Bootstrap {
        this._handler = handler;
        return this;
    }

    public function connect(host:String, port:uint):IChannelFuture {
        _validate();

        var channel:IChannel = new _channelClass();

        const pipeline:IChannelPipeline = channel.pipeline;
        if (!pipeline)
            throw "Null pipeline.";

        pipeline.addLast(getQualifiedClassName(_handler), _handler);

        var future:IChannelFuture = channel.connect(host, port);

        future.addEventListener(ChannelFutureEvent.OPERATION_COMPLETE, _future_operationComplete, false, 0, true);

        function _future_operationComplete(event:ChannelFutureEvent):void {
            future.removeEventListener(event.type, _future_operationComplete);

            if (event.data is Error) {
                // connected error.
            } else if (future.channel.isOpen) {
                // connected success.
            }
        }

        return future;
    }

    private function _validate():void {
        if (!_channelClass) {
            throw new Error("Channel class was null.");
        }
    }

    public function shutdown():IChannelFuture {
        return null;
    }

    public function Bootstrap() {
        super();
    }

}
}
