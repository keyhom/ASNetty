package io.asnetty.channel {

import io.asnetty.handler.IChannelHandler;
import io.asnetty.handler.IChannelHandlerContext;

/**
 * @author Jeremy
 */
public class ChannelHandlerAdapter implements IChannelHandler {

    public function ChannelHandlerAdapter() {
        super();
    }

    public function handlerAdded(ctx:IChannelHandlerContext):void {
        // NOOP.
    }

    public function handlerRemoved(ctx:IChannelHandlerContext):void {
        // NOOP.
    }

    public function errorCaught(ctx:IChannelHandlerContext, cause:Error):void {
        ctx.fireErrorCaught(cause);
    }

    public function channelActive(ctx:IChannelHandlerContext):void {
        ctx.fireChannelActive();
    }

    public function channelInactive(ctx:IChannelHandlerContext):void {
        ctx.fireChannelInactive();
    }

    public function channelRead(ctx:IChannelHandlerContext, msg:*):void {
        ctx.fireChannelRead(msg);
    }

    public function channelReadComplete(ctx:IChannelHandlerContext):void {
        ctx.fireChannelReadComplete();
    }

    public function channelWritabilityChanged(ctx:IChannelHandlerContext):void {
        ctx.fireChannelWritabilityChanged();
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
        ctx.makeWrite(msg, promise);
    }

    public function flush(ctx:IChannelHandlerContext):void {
        ctx.makeFlush();
    }

}
}
