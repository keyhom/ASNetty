package io.asnetty.channel {

import flash.utils.Dictionary;

import io.asnetty.handler.IChannelHandler;
import io.asnetty.handler.IChannelHandlerContext;
import io.asnetty.handler.IChannelHandlerInvoker;

/**
 * @author Jeremy
 */
public class DefaultChannelPipeline implements IChannelPipeline {

    private var _channel:IChannel;

    /** @private */
    private var _contexts:Vector.<DefaultChannelHandlerContext>;

    /**
     * Constructor.
     */
    public function DefaultChannelPipeline(channel:IChannel) {
        super();
        this._channel = channel;
        this._contexts = new <DefaultChannelHandlerContext>[];
    }

    public function addFirst(name:String, handler:IChannelHandler,
                             invoker:IChannelHandlerInvoker = null):IChannelPipeline {
        const ctx:DefaultChannelHandlerContext = new
                DefaultChannelHandlerContext(name, handler, invoker);
        _contexts.unshift(ctx);
        return this;
    }

    public function addLast(name:String, handler:IChannelHandler,
                            invoker:IChannelHandlerInvoker = null):IChannelPipeline {
        const ctx:DefaultChannelHandlerContext = new
                DefaultChannelHandlerContext(name, handler, invoker);
        _contexts.push(ctx);
        return this;
    }

    public function addBefore(baseName:String, name:String,
                              handler:IChannelHandler, invoker:IChannelHandlerInvoker =
                                      null):IChannelPipeline {
        var idx:uint = 0;
        var found:Boolean = false;
        for each (var c:DefaultChannelHandlerContext in _contexts) {
            if (c.name == baseName) {
                // Found base handler.
                found = true;
                break;
            }
            idx++;
        }

        if (!found)
            throw new Error("Cann't find the base handler named: " + baseName);

        _contexts.splice(idx, 0, new DefaultChannelHandlerContext(name, handler, invoker));

        return this;
    }

    public function addAfter(baseName:String, name:String,
                             handler:IChannelHandler, invoker:IChannelHandlerInvoker =
                                     null):IChannelPipeline {
        var idx:uint = 0;
        var found:Boolean = false;
        for each (var c:DefaultChannelHandlerContext in _contexts) {
            idx++;
            if (c.name == baseName) {
                // Found base handler.
                found = true;
                break;
            }
        }

        if (!found)
            throw new Error("Cann't find the base handler named: " + baseName);

        _contexts.splice(idx, 0, new DefaultChannelHandlerContext(name, handler, invoker));

        return this;
    }

    public function remove(handler:IChannelHandler):IChannelHandler {
        if (!handler)
            return null;

        var idx:int = 0;
        for each (var c:DefaultChannelHandlerContext in _contexts) {
            if (c.handler == handler) {
                _contexts.splice(idx, 1);
                return handler;
            }
            idx++;
        }

        return null;
    }

    public function removeByName(name:String):IChannelHandler {
        if (!name)
            return null;

        var idx:int = 0;
        for each (var c:DefaultChannelHandlerContext in _contexts) {
            if (c.name == name) {
                _contexts.splice(idx, 1);
                return c.handler;
            }
            idx++;
        }

        return null;
    }

    public function removeByType(clazz:Class):Vector.<IChannelHandler> {
        if (!clazz)
            return null;

        var ret:Vector.<IChannelHandler> = new <IChannelHandler>[];

        for (var i:int = _contexts.length - 1; i >= 0; i--) {
            if (_contexts[i] && _contexts[i].handler is clazz) {
                ret.push(_contexts[i].handler);
                _contexts.splice(i, 1);
            }
        }

        return ret;
    }

    public function removeFirst():IChannelHandler {
        const ctx:DefaultChannelHandlerContext = _contexts.shift() as DefaultChannelHandlerContext;
        return ctx ? ctx.handler : null;
    }

    public function removeLast():IChannelHandler {
        const ctx:DefaultChannelHandlerContext = _contexts.pop() as DefaultChannelHandlerContext;
        return ctx ? ctx.handler : null;
    }

    public function replace(old:*, newName:String,
                            newHandler:IChannelHandler):IChannelPipeline {
        return null;
    }

    public function get channel():IChannel {
        return _channel;
    }

    public function get first():IChannelHandler {
        if (_contexts.length == 0)
            return null;
        return _contexts[0].handler;
    }

    public function get last():IChannelHandler {
        return _contexts[_contexts.length - 1].handler;
    }

    public function get firstContext():IChannelHandlerContext {
        return _contexts[0];
    }

    public function get lastContext():IChannelHandlerContext {
        if (_contexts.length > 0)
            return _contexts[_contexts.length - 1];
        return null;
    }

    public function get names():Vector.<String> {
        const vec:Vector.<String> = new <String>[];
        for each (var c:DefaultChannelHandlerContext in _contexts) {
            vec.push(c.name);
        }
        return vec;
    }

    public function toMap():Dictionary {
        const dic:Dictionary = new Dictionary();
        for each (var c:DefaultChannelHandlerContext in _contexts) {
            dic[c.name] = c.handler;
        }
        return dic;
    }

    public function getHandler(byWhat:*):IChannelHandler {
        if (byWhat is String) {
            for each (var c:DefaultChannelHandlerContext in _contexts) {
                if (c.name == byWhat)
                    return c.handler;
            }
        } else if (byWhat is Class) {
            for each (var c:DefaultChannelHandlerContext in _contexts) {
                if (c.handler is byWhat)
                    return c.handler;
            }
        } else {
            // NOOP
        }
        return null;
    }

    public function context(nameOrInstanceOrClass:*):IChannelHandlerContext {
        const name:String = nameOrInstanceOrClass is String ? String(nameOrInstanceOrClass) : nameOrInstanceOrClass.toString();
        const instance:IChannelHandler = nameOrInstanceOrClass as IChannelHandler;
        return new DefaultChannelHandlerContext(name, instance);
    }

    public function fireChannelActive():IChannelPipeline {
        return null;
    }

    public function fireChannelInactive():IChannelPipeline {
        return null;
    }

    public function fireErrorCaught(cause:Error):IChannelPipeline {
        if (cause)
            throw cause;
        return this;
    }

    public function fireChannelRead(msg:Object):IChannelPipeline {
        return null;
    }

    public function fireChannelReadComplete():IChannelPipeline {
        return null;
    }

    public function fireChannelWritabilityChanged():IChannelPipeline {
        return null;
    }

    public function connect(host:String, port:uint, promise:IChannelPromise =
            null):IChannelFuture {
        return null;
    }

    public function disconnect(promise:IChannelPromise = null):IChannelFuture {
        return null;
    }

    public function close(promise:IChannelPromise = null):IChannelFuture {
        return null;
    }

    public function read():IChannelPipeline {
        return null;
    }

    public function write(msg:*, promise:IChannelPromise = null):IChannelPipeline {
        return null;
    }

    public function flush():IChannelPipeline {
        return null;
    }

    public function writeAndFlush(msg:*, promise:IChannelPromise =
            null):IChannelFuture {
        return null;
    }

} // class DefaultChannelPipeline
}

import io.asnetty.handler.IChannelHandler;
import io.asnetty.handler.IChannelHandlerContext;
import io.asnetty.handler.IChannelHandlerInvoker;

/**
 * @author Jeremy
 */
class DefaultChannelHandlerContext implements IChannelHandlerContext {

    public var name:String;
    private var _handler:IChannelHandler;
    public var invoker:IChannelHandlerInvoker;

    public function DefaultChannelHandlerContext(name:String,
                                                 handler:IChannelHandler, invoker:IChannelHandlerInvoker = null) {
        this.name = name;
        this._handler = handler;
        this.invoker = invoker;
    }

    public function get handler():IChannelHandler {
        return _handler;
    }

}

class HeadContext extends DefaultChannelHandlerContext {

    function HeadContext(name:String, handler:IChannelHandler, invoker:IChannelHandlerInvoker = null) {
        super(name, handler, invoker);
    }
}

class TailContext extends DefaultChannelHandlerContext implements IChannelHandler {

    function TailContext(name:String, handler:IChannelHandler, invoker:IChannelHandlerInvoker = null) {
        super(name, handler, invoker);
    }

    public override function get handler():IChannelHandler {
        return this;
    }

    public function handlerAdded(ctx:IChannelHandlerContext):void {
    }

    public function handlerRemoved(ctx:IChannelHandlerContext):void {
    }

    public function errorCaught(ctx:IChannelHandlerContext, cause:Error):void {
    }

}

