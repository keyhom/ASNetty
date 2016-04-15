package io.asnetty.channel {

import flash.utils.Dictionary;

import io.asnetty.handler.IChannelHandler;
import io.asnetty.handler.IChannelHandlerContext;

/**
 * @author Jeremy
 */
public class DefaultChannelPipeline implements IChannelPipeline {

    private var _channel:IChannel;
    private var _head:HeadContext;
    private var _tail:TailContext;

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

    public function addFirst(name:String, handler:IChannelHandler):IChannelPipeline {
        const ctx:DefaultChannelHandlerContext = new
                DefaultChannelHandlerContext(this, name, handler, true, true);
        _contexts.unshift(ctx);
        return this;
    }

    public function addLast(name:String, handler:IChannelHandler):IChannelPipeline {
        const ctx:DefaultChannelHandlerContext = new
                DefaultChannelHandlerContext(this, name, handler, true, true);
        _contexts.push(ctx);
        return this;
    }

    public function addBefore(baseName:String, name:String,
                              handler:IChannelHandler):IChannelPipeline {
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

        _contexts.splice(idx, 0, new DefaultChannelHandlerContext(this, name, handler, true, true));

        return this;
    }

    public function addAfter(baseName:String, name:String,
                             handler:IChannelHandler):IChannelPipeline {
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

        _contexts.splice(idx, 0, new DefaultChannelHandlerContext(this, name, handler, true, true));

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
        var ctx:IChannelHandlerContext = firstContext;
        if (ctx) {
            return ctx.handler;
        }
        return null;
    }

    public function get last():IChannelHandler {
        var ctx:IChannelHandlerContext = lastContext;
        if (ctx)
            return ctx.handler;
        return null;
    }

    public function get firstContext():IChannelHandlerContext {
        var first:DefaultChannelHandlerContext = _head.next;
        if (first != _tail) {
            return first;
        }
        return null;
    }

    public function get lastContext():IChannelHandlerContext {
        var last:DefaultChannelHandlerContext = _tail.prev;
        if (last != _head)
            return last;
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
            //noinspection JSDuplicatedDeclaration
            for each (var c:DefaultChannelHandlerContext in _contexts) {
                if (c.name == byWhat)
                    return c.handler;
            }
        }
        else if (byWhat is Class) {
            //noinspection JSDuplicatedDeclaration
            for each (var c:DefaultChannelHandlerContext in _contexts) {
                if (c.handler is byWhat)
                    return c.handler;
            }
        }
        else {
            // NOOP
        }
        return null;
    }

    public function context(nameOrInstanceOrClass:*):IChannelHandlerContext {
        const name:String = nameOrInstanceOrClass is String ? String(nameOrInstanceOrClass) : nameOrInstanceOrClass.toString();
        const instance:IChannelHandler = nameOrInstanceOrClass as IChannelHandler;
        return new DefaultChannelHandlerContext(this, name, instance, true, true);
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

import io.asnetty.channel.DefaultChannelPipeline;
import io.asnetty.channel.IChannel;
import io.asnetty.channel.IChannelFuture;
import io.asnetty.channel.IChannelPipeline;
import io.asnetty.channel.IChannelPromise;
import io.asnetty.handler.IChannelHandler;
import io.asnetty.handler.IChannelHandlerContext;

/**
 * @author Jeremy
 */
class DefaultChannelHandlerContext implements IChannelHandlerContext {

    private var _name:String;
    private var _handler:IChannelHandler;
    private var _pipeline:DefaultChannelPipeline;
    private var _handlerRemoved:Boolean;
    private var _succeededFuture:IChannelFuture;

    public var prev:DefaultChannelHandlerContext;
    public var next:DefaultChannelHandlerContext;

    private var _inbound:Boolean;
    private var _outbound:Boolean;

    public function DefaultChannelHandlerContext(pipeline:DefaultChannelPipeline, name:String,
                                                 handler:IChannelHandler,
                                                 inbound:Boolean,
                                                 outbound:Boolean) {
        super();

        this._name = name;
        this._handler = handler;
        this._inbound = inbound;
        this._outbound = outbound;
    }

    public function get name():String {
        return _name;
    }

    public function get handler():IChannelHandler {
        return _handler;
    }

    public function get channel():IChannel {
        return _pipeline.channel;
    }

    public function get isRemoved():Boolean {
        return _handlerRemoved;
    }

    public function get pipeline():IChannelPipeline {
        return _pipeline;
    }

    public function fireChannelActive():IChannelHandlerContext {
        const next:DefaultChannelHandlerContext = this.findContextInbound();
        next.invokeChannelActive();
        return this;
    }

    public function fireChannelInactive():IChannelHandlerContext {
        const next:DefaultChannelHandlerContext = this.findContextInbound();
        next.invokeChannelInactive();
        return this;
    }

    public function fireErrorCaught(cause:Error):IChannelHandlerContext {
        const next:DefaultChannelHandlerContext = this.next;
        next.invokeErrorCaught(cause);
        return this;
    }

    public function fireChannelRead(msg:*):IChannelHandlerContext {
        const next:DefaultChannelHandlerContext = this.findContextInbound();
        next.invokeChannelRead(msg);
        return this;
    }

    public function fireChannelReadComplete():IChannelHandlerContext {
        const next:DefaultChannelHandlerContext = this.findContextInbound();
        next.invokeChannelReadComplete();
        return this;
    }

    public function fireChannelWritabilityChanged():IChannelHandlerContext {
        const next:DefaultChannelHandlerContext = this.findContextInbound();
        next.invokeChannelWritabilityChanged();
        return this;
    }

    public function makeConnect(host:String, port:int, promise:IChannelPromise = null):IChannelFuture {
        const next:DefaultChannelHandlerContext = this.findContextOutbound();
        next.invokeConnect(host, port, promise);
        return promise;
    }

    public function makeDisconnect(promise:IChannelPromise = null):IChannelFuture {
        // close directly if disconnecting not supported.
        const next:DefaultChannelHandlerContext = this.findContextOutbound();
        next.invokeDisconnect(promise);
        return promise;
    }

    public function makeClose(promise:IChannelPromise = null):IChannelFuture {
        const next:DefaultChannelHandlerContext = this.findContextOutbound();
        next.invokeClose(promise);
        return promise;
    }

    public function makeRead():IChannelHandlerContext {
        const next:DefaultChannelHandlerContext = this.findContextOutbound();
        next.invokeRead();
        return this;
    }

    public function makeWrite(obj:*, promise:IChannelPromise = null):IChannelFuture {
        const next:DefaultChannelHandlerContext = this.findContextOutbound();
        next.invokeWrite(obj, promise);
        return promise;
    }

    public function makeFlush():IChannelHandlerContext {
        const next:DefaultChannelHandlerContext = this.findContextOutbound();
        next.invokeFlush();
        return this;
    }

    public function makeWriteAndFlush(msg:*, promise:IChannelPromise = null):IChannelFuture {
        const next:DefaultChannelHandlerContext = this.findContextOutbound();
        next.invokeWriteAndFlush(msg, promise);
        return promise;
    }

    private function findContextInbound():DefaultChannelHandlerContext {
        var ctx:DefaultChannelHandlerContext = this;
        do {
            ctx = ctx.next;
        } while (!ctx._inbound);
        return ctx;
    }

    private function findContextOutbound():DefaultChannelHandlerContext {
        var ctx:DefaultChannelHandlerContext = this;
        do {
            ctx = ctx.prev;
        } while (!ctx._outbound);
        return ctx;
    }

    internal function invokeChannelActive():void {
        handler.channelActive(this);
    }

    internal function invokeChannelInactive():void {
        handler.channelInactive(this);
    }

    internal function invokeErrorCaught(cause:Error):void {
        handler.errorCaught(this, cause);
    }

    internal function invokeChannelRead(msg:*):void {
        handler.channelRead(this, msg);
    }

    internal function invokeChannelReadComplete():void {
        handler.channelReadComplete(this);
    }

    internal function invokeChannelWritabilityChanged():void {
        handler.channelWritabilityChanged(this);
    }

    internal function invokeConnect(host:String, port:int, promise:IChannelPromise):void {
        handler.connect(this, host, port, promise);
    }

    internal function invokeDisconnect(promise:IChannelPromise):void {
        handler.disconnect(this, promise);
    }

    internal function invokeClose(promise:IChannelPromise):void {
        handler.close(this, promise);
    }

    internal function invokeRead():void {
        handler.read(this);
    }

    internal function invokeWrite(obj:*, promise:IChannelPromise):void {
        handler.write(this, obj, promise);
    }

    internal function invokeFlush():void {
        handler.flush(this);
    }

    internal function invokeWriteAndFlush(msg:*, promise:IChannelPromise):void {
        handler.write(this, msg, promise);
        handler.flush(this);
    }

}

/**
 * @author Jeremy
 */
class HeadContext extends DefaultChannelHandlerContext implements IChannelHandler {

    public function HeadContext(pipeline:DefaultChannelPipeline) {
        super(pipeline, "HeadContext", this, false, true);
    }

    public function handlerAdded(ctx:IChannelHandlerContext):void {
    }

    public function handlerRemoved(ctx:IChannelHandlerContext):void {
    }

    public function errorCaught(ctx:IChannelHandlerContext, cause:Error):void {
    }

    public function channelActive(ctx:IChannelHandlerContext):void {
    }

    public function channelInactive(ctx:IChannelHandlerContext):void {
    }

    public function channelRead(ctx:IChannelHandlerContext, msg:*):void {
    }

    public function channelReadComplete(ctx:IChannelHandlerContext):void {
    }

    public function channelWritabilityChanged(ctx:IChannelHandlerContext):void {
    }

    public function connect(ctx:IChannelHandlerContext, host:String, port:int, promise:IChannelPromise = null):void {
    }

    public function disconnect(ctx:IChannelHandlerContext, promise:IChannelPromise = null):void {
    }

    public function close(ctx:IChannelHandlerContext, promise:IChannelPromise = null):void {
    }

    public function read(ctx:IChannelHandlerContext):void {
    }

    public function write(ctx:IChannelHandlerContext, msg:*, promise:IChannelPromise = null):void {
    }

    public function flush(ctx:IChannelHandlerContext):void {
    }
}

/**
 * @author Jeremy
 */
class TailContext extends DefaultChannelHandlerContext implements IChannelHandler {

    public function TailContext(pipeline:DefaultChannelPipeline) {
        super(pipeline, "TailContext", this, true, false);
    }

    public function handlerAdded(ctx:IChannelHandlerContext):void {
    }

    public function handlerRemoved(ctx:IChannelHandlerContext):void {
    }

    public function errorCaught(ctx:IChannelHandlerContext, cause:Error):void {
    }

    public function channelActive(ctx:IChannelHandlerContext):void {
    }

    public function channelInactive(ctx:IChannelHandlerContext):void {
    }

    public function channelRead(ctx:IChannelHandlerContext, msg:*):void {
    }

    public function channelReadComplete(ctx:IChannelHandlerContext):void {
    }

    public function channelWritabilityChanged(ctx:IChannelHandlerContext):void {
    }

    public function connect(ctx:IChannelHandlerContext, host:String, port:int, promise:IChannelPromise = null):void {
        ctx.makeConnect(host, port, promise);
    }

    public function disconnect(ctx:IChannelHandlerContext, promise:IChannelPromise = null):void {
        ctx.makeDisconnect(promise);
    }

    public function close(ctx:IChannelHandlerContext, promise:IChannelPromise = null):void {
        ctx.makeClose(promise);
    }

    public function read(ctx:IChannelHandlerContext):void {
        ctx.makeRead();
    }

    public function write(ctx:IChannelHandlerContext, msg:*, promise:IChannelPromise = null):void {

    }

    public function flush(ctx:IChannelHandlerContext):void {
        ctx.makeFlush();
    }

}

