package io.asnetty.bootstrap {

import avmplus.getQualifiedClassName;

import flash.events.EventDispatcher;

import io.asnetty.channel.IChannel;
import io.asnetty.channel.IChannelFuture;
import io.asnetty.channel.IChannelHandler;
import io.asnetty.channel.IChannelPipeline;

[Event(name="complete", type="flash.events.Event")]
/**
 *
 * @author Jeremy
 */
public class Bootstrap extends EventDispatcher {

    private var _channelClass:Class;
    private var _options:Object;
    private var _handler:IChannelHandler;
    private var _channel:IChannel;

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

    public function connect(host:String, port:uint, timeout:Number = 30):IChannelFuture {
        _validate();

        const channel:IChannel = new _channelClass();

        try {
            const pipeline:IChannelPipeline = channel.pipeline;
            if (!pipeline)
                throw "Null pipeline.";

            pipeline.addLast(getQualifiedClassName(_handler), _handler);

        } finally {
            this._channel = channel;
        }

        return channel.connect(host, port, timeout);
    }

    private function _validate():void {
        if (!_channelClass) {
            throw new Error("Channel class was null.");
        }
    }

    public function shutdown():IChannelFuture {
        if (_channel) {
            return _channel.close();
        }
        return null;
    }

    public function Bootstrap() {
        super();
    }

}
}
