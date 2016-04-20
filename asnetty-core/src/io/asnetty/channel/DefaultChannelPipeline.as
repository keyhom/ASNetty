package io.asnetty.channel {

import avmplus.getQualifiedClassName;

import flash.utils.Dictionary;

/**
 * @author Jeremy
 */
public class DefaultChannelPipeline implements IChannelPipeline {

    private var _channel:AbstractChannel;
    private var _head:HeadContext;
    private var _tail:TailContext;

    private var _name2ctx:Object;

    /**
     * Constructor.
     */
    public function DefaultChannelPipeline(channel:AbstractChannel) {
        super();
        this._channel = channel;
        this._name2ctx = {};

        this._tail = new TailContext(this);
        this._head = new HeadContext(this);

        this._head.next = this._tail;
        this._tail.prev = this._head;
    }

    public function addFirst(name:String, handler:IChannelHandler):IChannelPipeline {
        const newCtx:DefaultChannelHandlerContext = new
                DefaultChannelHandlerContext(this, name, handler);
        const nextCtx:DefaultChannelHandlerContext = _head.next;
        newCtx.prev = _head;
        newCtx.next = nextCtx;
        _head.next = newCtx;
        nextCtx.prev = newCtx;

        _name2ctx[name] = newCtx;

        callHandlerAdded(newCtx);
        return this;
    }

    public function addLast(name:String, handler:IChannelHandler):IChannelPipeline {
        const newCtx:DefaultChannelHandlerContext = new
                DefaultChannelHandlerContext(this, name, handler);
        const prev:DefaultChannelHandlerContext = _tail.prev;
        newCtx.prev = prev;
        newCtx.next = _tail;
        prev.next = newCtx;
        _tail.prev = newCtx;

        _name2ctx[name] = newCtx;

        callHandlerAdded(newCtx);
        return this;
    }

    public function addBefore(baseName:String, name:String,
                              handler:IChannelHandler):IChannelPipeline {
        const newCtx:DefaultChannelHandlerContext = new
                DefaultChannelHandlerContext(this, name, handler);
        const ctx:DefaultChannelHandlerContext = this.context(baseName) as DefaultChannelHandlerContext;

        newCtx.prev = ctx.prev;
        newCtx.next = ctx;
        ctx.prev.next = newCtx;
        ctx.prev = newCtx;

        _name2ctx[name] = newCtx;

        callHandlerAdded(newCtx);
        return this;
    }

    public function addAfter(baseName:String, name:String,
                             handler:IChannelHandler):IChannelPipeline {
        const newCtx:DefaultChannelHandlerContext = new
                DefaultChannelHandlerContext(this, name, handler);
        const ctx:DefaultChannelHandlerContext = this.context(baseName) as DefaultChannelHandlerContext;

        newCtx.prev = ctx;
        newCtx.next = ctx.next;
        ctx.next.prev = newCtx;
        ctx.next = newCtx;

        _name2ctx[name] = newCtx;

        callHandlerAdded(newCtx);
        return this;
    }

    private function callHandlerAdded(newCtx:DefaultChannelHandlerContext):void {
        try {
            newCtx.handler.handlerAdded(newCtx);
        } catch (e:Error) {
            var removed:Boolean = false;
            try {
                this.removeContext(newCtx);
                removed = true;
            } catch (e2:Error) {
                // NOOP.
            }

            if (removed) {
                fireErrorCaught(new Error(getQualifiedClassName(newCtx.handler) +
                        ".handlerAdded() has caught error; removed."));
            } else {
                fireErrorCaught(new Error(getQualifiedClassName(newCtx.handler) +
                        ".handlerAdded() has caught error; also failed to remove."));
            }
        }
    }

    private function callHandlerRemoved(newCtx:DefaultChannelHandlerContext):void {
        try {
            newCtx.handler.handlerRemoved(newCtx);
            newCtx.setRemoved();
        } catch (e:Error) {
            fireErrorCaught(new Error(getQualifiedClassName(newCtx.handler) +
                    ".handlerRemoved() has caught an error."));
        }
    }

    private function removeContext(ctx:DefaultChannelHandlerContext):DefaultChannelHandlerContext {
        const prev:DefaultChannelHandlerContext = ctx.prev;
        const next:DefaultChannelHandlerContext = ctx.next;
        prev.next = next;
        next.prev = prev;

        delete _name2ctx[ctx.name];

        callHandlerRemoved(ctx);

        return ctx;
    }

    public function remove(handler:IChannelHandler):IChannelPipeline {
        removeContext(context(handler) as DefaultChannelHandlerContext);
        return this;
    }

    public function removeByName(name:String):IChannelPipeline {
        removeContext(context(name) as DefaultChannelHandlerContext);
        return this;
    }

    public function removeByType(clazz:Class):IChannelPipeline {
        if (!clazz)
            return null;

        removeContext(context(clazz) as DefaultChannelHandlerContext);

        return this;
    }

    public function removeFirst():IChannelHandler {
        if (_head.next == _tail)
            throw "NoSuchElement in .removeFirst()";
        return removeContext(_head.next).handler;
    }

    public function removeLast():IChannelHandler {
        if (_tail.prev == _head) {
            throw "NoSuchElement in .removeLast()";
        }
        return removeContext(_tail.prev).handler;
    }

    public function replace(old:*, newName:String,
                            newHandler:IChannelHandler):IChannelPipeline {
        const oldCtx:DefaultChannelHandlerContext = context(old) as DefaultChannelHandlerContext;
        const newCtx:DefaultChannelHandlerContext = new
                DefaultChannelHandlerContext(this, newName, newHandler);

        const prev:DefaultChannelHandlerContext = oldCtx.prev;
        const next:DefaultChannelHandlerContext = oldCtx.next;

        newCtx.prev = prev;
        newCtx.next = next;

        // Finish the replacement of oldCtx with newCtx in the linked list.

        prev.next = newCtx;
        next.prev = newCtx;

        if (oldCtx.name != newName)
            delete _name2ctx[oldCtx.name];

        _name2ctx[newName] = newCtx;

        // update the reference to the replacement so forward of buffered content will
        // work correctly.
        oldCtx.prev = newCtx;
        oldCtx.next = newCtx;

        // Invoke newHandler.handlerAdded first.

        callHandlerAdded(newCtx);
        callHandlerRemoved(oldCtx);

        return this;
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
        var ctx:DefaultChannelHandlerContext = _head.next;
        for (; ;) {
            if (!ctx)
                return vec;
            vec.push(ctx.name);
            ctx = ctx.next;
        }
    }

    public function toMap():Dictionary {
        const dic:Dictionary = new Dictionary();
        var ctx:DefaultChannelHandlerContext = _head.next;
        for (; ;) {
            if (!ctx)
                return dic;
            dic[ctx.name] = ctx.handler;
            ctx = ctx.next;
        }
    }

    public function context(nameOrInstanceOrClass:*):IChannelHandlerContext {
        var ctx:DefaultChannelHandlerContext = _head.next;
        for (; ;) {
            if (null == ctx) {
                return null;
            }

            if (nameOrInstanceOrClass is Class && ctx is nameOrInstanceOrClass)
                return ctx;
            else if (nameOrInstanceOrClass is String && ctx.name == nameOrInstanceOrClass)
                return ctx;
            else if (nameOrInstanceOrClass is IChannelHandler && ctx.handler == nameOrInstanceOrClass)
                return ctx;
            ctx = ctx.next;
        }
    }

    public function fireChannelActive():IChannelPipeline {
        _head.fireChannelActive();

        if (channel.config.autoRead) {
            channel.read();
        }

        return this;
    }

    public function fireChannelInactive():IChannelPipeline {
        _head.fireChannelInactive();
        return this;
    }

    public function fireErrorCaught(cause:Error):IChannelPipeline {
        _head.fireErrorCaught(cause);
        return this;
    }

    public function fireChannelRead(msg:Object):IChannelPipeline {
        _head.fireChannelRead(msg);
        return this;
    }

    public function fireChannelReadComplete():IChannelPipeline {
        _head.fireChannelReadComplete();
        if (channel.config.autoRead && channel.isOpen)
            read();
        return this;
    }

    public function fireChannelWritabilityChanged():IChannelPipeline {
        _head.fireChannelWritabilityChanged();
        return this;
    }

    public function connect(host:String, port:uint, promise:IChannelPromise =
            null):IChannelFuture {
        return _tail.makeConnect(host, port, promise);
    }

    public function disconnect(promise:IChannelPromise = null):IChannelFuture {
        return _tail.makeDisconnect(promise);
    }

    public function close(promise:IChannelPromise = null):IChannelFuture {
        return _tail.makeClose(promise);
    }

    public function read():IChannelPipeline {
        _tail.makeRead();
        return this;
    }

    public function write(msg:*, promise:IChannelPromise = null):IChannelFuture {
        return _tail.makeWrite(msg, promise);
    }

    public function flush():IChannelPipeline {
        _tail.makeFlush();
        return this;
    }

    public function writeAndFlush(msg:*, promise:IChannelPromise =
            null):IChannelFuture {
        return _tail.makeWriteAndFlush(msg, promise);
    }

} // class DefaultChannelPipeline
}

import io.asnetty.channel.DefaultChannelPipeline;
import io.asnetty.channel.DefaultChannelPromise;
import io.asnetty.channel.IChannel;
import io.asnetty.channel.IChannelFuture;
import io.asnetty.channel.IChannelHandler;
import io.asnetty.channel.IChannelHandlerContext;
import io.asnetty.channel.IChannelInboundHandler;
import io.asnetty.channel.IChannelOutboundHandler;
import io.asnetty.channel.IChannelPipeline;
import io.asnetty.channel.IChannelPromise;

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

    /**
     * Constructor
     */
    public function DefaultChannelHandlerContext(pipeline:DefaultChannelPipeline, name:String,
                                                 handler:IChannelHandler) {
        super();

        this._pipeline = pipeline;
        this._name = name;
        this._handler = handler;
        this._inbound = handler is IChannelInboundHandler;
        this._outbound = handler is IChannelOutboundHandler;
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

    public function setRemoved():void {
        _handlerRemoved = true;
    }

    public function get pipeline():IChannelPipeline {
        return _pipeline;
    }

    public function fireChannelActive():IChannelHandlerContext {
        const next:DefaultChannelHandlerContext = findContextInbound();
        next.invokeChannelActive();
        return this;
    }

    public function fireChannelInactive():IChannelHandlerContext {
        const next:DefaultChannelHandlerContext = findContextInbound();
        next.invokeChannelInactive();
        return this;
    }

    public function fireErrorCaught(cause:Error):IChannelHandlerContext {
        const next:DefaultChannelHandlerContext = next;
        next.invokeErrorCaught(cause);
        return this;
    }

    public function fireChannelRead(msg:*):IChannelHandlerContext {
        const next:DefaultChannelHandlerContext = findContextInbound();
        next.invokeChannelRead(msg);
        return this;
    }

    public function fireChannelReadComplete():IChannelHandlerContext {
        const next:DefaultChannelHandlerContext = findContextInbound();
        next.invokeChannelReadComplete();
        return this;
    }

    public function fireChannelWritabilityChanged():IChannelHandlerContext {
        const next:DefaultChannelHandlerContext = findContextInbound();
        next.invokeChannelWritabilityChanged();
        return this;
    }

    public function makeConnect(host:String, port:int, promise:IChannelPromise = null):IChannelFuture {
        const next:DefaultChannelHandlerContext = findContextOutbound();
        if (!promise)
            promise = new DefaultChannelPromise(channel);
        next.invokeConnect(host, port, promise);
        return promise;
    }

    public function makeDisconnect(promise:IChannelPromise = null):IChannelFuture {
        // close directly if disconnecting not supported.
        const next:DefaultChannelHandlerContext = findContextOutbound();
        if (!promise)
            promise = new DefaultChannelPromise(channel);
        next.invokeDisconnect(promise);
        return promise;
    }

    public function makeClose(promise:IChannelPromise = null):IChannelFuture {
        const next:DefaultChannelHandlerContext = findContextOutbound();
        if (!promise)
            promise = new DefaultChannelPromise(channel);
        next.invokeClose(promise);
        return promise;
    }

    public function makeRead():IChannelHandlerContext {
        const next:DefaultChannelHandlerContext = findContextOutbound();
        next.invokeRead();
        return this;
    }

    public function makeWrite(obj:*, promise:IChannelPromise = null):IChannelFuture {
        const next:DefaultChannelHandlerContext = findContextOutbound();
        if (!promise)
            promise = new DefaultChannelPromise(channel);
        next.invokeWrite(obj, promise);
        return promise;
    }

    public function makeFlush():IChannelHandlerContext {
        const next:DefaultChannelHandlerContext = findContextOutbound();
        next.invokeFlush();
        return this;
    }

    public function makeWriteAndFlush(msg:*, promise:IChannelPromise = null):IChannelFuture {
        const next:DefaultChannelHandlerContext = findContextOutbound();
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
        (handler as IChannelInboundHandler).channelActive(this);
    }

    internal function invokeChannelInactive():void {
        (handler as IChannelInboundHandler).channelInactive(this);
    }

    internal function invokeErrorCaught(cause:Error):void {
        handler.errorCaught(this, cause);
    }

    internal function invokeChannelRead(msg:*):void {
        (handler as IChannelInboundHandler).channelRead(this, msg);
    }

    internal function invokeChannelReadComplete():void {
        (handler as IChannelInboundHandler).channelReadComplete(this);
    }

    internal function invokeChannelWritabilityChanged():void {
        (handler as IChannelInboundHandler).channelWritabilityChanged(this);
    }

    internal function invokeConnect(host:String, port:int, promise:IChannelPromise):void {
        (handler as IChannelOutboundHandler).connect(this, host, port, promise);
    }

    internal function invokeDisconnect(promise:IChannelPromise):void {
        (handler as IChannelOutboundHandler).disconnect(this, promise);
    }

    internal function invokeClose(promise:IChannelPromise):void {
        (handler as IChannelOutboundHandler).close(this, promise);
    }

    internal function invokeRead():void {
        (handler as IChannelOutboundHandler).read(this);
    }

    internal function invokeWrite(obj:*, promise:IChannelPromise):void {
        (handler as IChannelOutboundHandler).write(this, obj, promise);
    }

    internal function invokeFlush():void {
        (handler as IChannelOutboundHandler).flush(this);
    }

    internal function invokeWriteAndFlush(msg:*, promise:IChannelPromise):void {
        var h:IChannelOutboundHandler = this.handler as IChannelOutboundHandler;
        h.write(this, msg, promise);
        h.flush(this);
    }

}

/**
 * @author Jeremy
 */
class HeadContext extends DefaultChannelHandlerContext implements IChannelOutboundHandler {

    /**
     * Constructor
     */
    public function HeadContext(pipeline:DefaultChannelPipeline) {
        super(pipeline, "HeadContext", this);
    }

    public function handlerAdded(ctx:IChannelHandlerContext):void {
        // NOOP
    }

    public function handlerRemoved(ctx:IChannelHandlerContext):void {
        // NOOP
    }

    public function errorCaught(ctx:IChannelHandlerContext, cause:Error):void {
        ctx.fireErrorCaught(cause);
    }

    public function connect(ctx:IChannelHandlerContext, host:String, port:int, promise:IChannelPromise = null):void {
        channel.unsafe.connect(host, port, promise);
    }

    public function disconnect(ctx:IChannelHandlerContext, promise:IChannelPromise = null):void {
        channel.unsafe.disconnect(promise);
    }

    public function close(ctx:IChannelHandlerContext, promise:IChannelPromise = null):void {
        channel.unsafe.close(promise);
    }

    public function read(ctx:IChannelHandlerContext):void {
        channel.unsafe.beginRead();
    }

    public function write(ctx:IChannelHandlerContext, msg:*, promise:IChannelPromise = null):void {
        channel.unsafe.write(msg, promise);
    }

    public function flush(ctx:IChannelHandlerContext):void {
        channel.unsafe.flush();
    }
}

/**
 * @author Jeremy
 */
class TailContext extends DefaultChannelHandlerContext implements IChannelInboundHandler {

    public function TailContext(pipeline:DefaultChannelPipeline) {
        super(pipeline, "TailContext", this);
    }

    public function handlerAdded(ctx:IChannelHandlerContext):void {
        // NOOP
    }

    public function handlerRemoved(ctx:IChannelHandlerContext):void {
        // NOOP
    }

    public function errorCaught(ctx:IChannelHandlerContext, cause:Error):void {
        // NOOP
    }

    public function channelActive(ctx:IChannelHandlerContext):void {
        // NOOP
    }

    public function channelInactive(ctx:IChannelHandlerContext):void {
        // NOOP
    }

    public function channelRead(ctx:IChannelHandlerContext, msg:*):void {
        // NOOP
    }

    public function channelReadComplete(ctx:IChannelHandlerContext):void {
        // NOOP
    }

    public function channelWritabilityChanged(ctx:IChannelHandlerContext):void {
        // NOOP
    }

}

