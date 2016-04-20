package {

import flash.display.Sprite;
import flash.events.Event;
import flash.utils.ByteArray;

import io.asnetty.bootstrap.Bootstrap;
import io.asnetty.channel.ChannelFutureEvent;
import io.asnetty.channel.ChannelInitializer;
import io.asnetty.channel.IChannel;
import io.asnetty.channel.IChannelFuture;
import io.asnetty.channel.IChannelPipeline;
import io.asnetty.channel.SocketChannel;

public class Main extends Sprite {

    public function Main() {
        if (stage) {
            addToStage(null);
        } else {
            addEventListener(Event.ADDED_TO_STAGE, addToStage);
        }
    }

    private function addToStage(event:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, addToStage);

        this.start();
    }

    private function start():void {
        var bs:Bootstrap = new Bootstrap();

        var f:IChannelFuture = bs.channel(SocketChannel).handler(new ChannelInitializer(function (ch:IChannel):void {
            const pipeline:IChannelPipeline = ch.pipeline;
            trace("Channel initializer callbacks.");

            pipeline.addLast("TestHandler", new TestChannelHandler());

        })).connect("www.baidu.com", 80);

        var operationComplete:Function;
        f.addEventListener(ChannelFutureEvent.OPERATION_COMPLETE, operationComplete = function (event:ChannelFutureEvent):void {
            f.removeEventListener(ChannelFutureEvent.OPERATION_COMPLETE, operationComplete);
            trace("Operation Completed.");

            var bs:ByteArray = new ByteArray();
            var str:String = "GET / HTTP/1.1\r\n";
            str += "Host: www.baidu.com\r\n";
            str += "Connection: Keep-Alive\r\n";
            bs.writeUTFBytes(str + "\r\n");
            f.channel.writeAndFlush(bs);
        });
    }

}
}

import io.asnetty.channel.ChannelHandlerAdapter;
import io.asnetty.channel.IChannelHandlerContext;
import io.asnetty.channel.IChannelInboundHandler;
import io.asnetty.channel.IChannelOutboundHandler;
import io.asnetty.channel.IChannelPromise;

class TestChannelHandler extends ChannelHandlerAdapter implements IChannelInboundHandler, IChannelOutboundHandler {

    function TestChannelHandler() {
        super();
    }

    override public function errorCaught(ctx:IChannelHandlerContext, cause:Error):void {
        trace("TEST channelException.");
        super.errorCaught(ctx, cause);
    }

    public function channelActive(ctx:IChannelHandlerContext):void {
        trace("TEST channelActive.");
        ctx.fireChannelActive();
    }

    public function channelInactive(ctx:IChannelHandlerContext):void {
        trace("TEST channelInactive.");
        ctx.fireChannelInactive();
    }

    public function channelRead(ctx:IChannelHandlerContext, msg:*):void {
        trace("TEST channelRead: ", msg);
        ctx.fireChannelRead(msg);
    }

    public function channelReadComplete(ctx:IChannelHandlerContext):void {
        trace("TEST channelReadComplete.");
        ctx.fireChannelReadComplete();
        ctx.makeClose();
    }

    public function channelWritabilityChanged(ctx:IChannelHandlerContext):void {
        trace("TEST channelWrite.");
        ctx.fireChannelWritabilityChanged();
    }

    public function connect(ctx:IChannelHandlerContext, host:String, port:int, promise:IChannelPromise = null):void {
        trace("TEST connect.");
        ctx.makeConnect(host, port, promise);
    }

    public function disconnect(ctx:IChannelHandlerContext, promise:IChannelPromise = null):void {
        trace("TEST disconnect.");
        ctx.makeDisconnect(promise);
    }

    public function close(ctx:IChannelHandlerContext, promise:IChannelPromise = null):void {
        trace("TEST close.");
        ctx.makeClose(promise);
    }

    public function read(ctx:IChannelHandlerContext):void {
        trace("TEST read.");
        ctx.makeRead();
    }

    public function write(ctx:IChannelHandlerContext, msg:*, promise:IChannelPromise = null):void {
        trace("TEST write.");
        ctx.makeWrite(msg, promise);
    }

    public function flush(ctx:IChannelHandlerContext):void {
        trace("TEST flush.");
        ctx.makeFlush();
    }

}
