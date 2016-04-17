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

        f.addEventListener(ChannelFutureEvent.OPERATION_COMPLETE, function (event:ChannelFutureEvent):void {
            trace("Operation Completed.");

            var bs:ByteArray = new ByteArray();
            bs.writeUTFBytes("GET / HTTP/1.1\n\n");
            f.channel.write(bs);

        }, false, 0, true);
    }

}
}

import io.asnetty.channel.ChannelHandlerAdapter;
import io.asnetty.channel.IChannelPromise;
import io.asnetty.handler.IChannelHandlerContext;

class TestChannelHandler extends ChannelHandlerAdapter {

    function TestChannelHandler() {
        super();
    }

    override public function errorCaught(ctx:IChannelHandlerContext, cause:Error):void {
        trace("TEST channelException.");
        super.errorCaught(ctx, cause);
    }

    override public function channelActive(ctx:IChannelHandlerContext):void {
        trace("TEST channelActive.");
        super.channelActive(ctx);
    }

    override public function channelInactive(ctx:IChannelHandlerContext):void {
        trace("TEST channelInactive.");
        super.channelInactive(ctx);
    }

    override public function channelRead(ctx:IChannelHandlerContext, msg:*):void {
        trace("TEST channelRead: ", msg);
        super.channelRead(ctx, msg);
    }

    override public function channelReadComplete(ctx:IChannelHandlerContext):void {
        trace("TEST channelReadComplete.");
        super.channelReadComplete(ctx);
    }

    override public function channelWritabilityChanged(ctx:IChannelHandlerContext):void {
        trace("TEST channelWrite.");
        super.channelWritabilityChanged(ctx);
    }

    override public function connect(ctx:IChannelHandlerContext, host:String, port:int, promise:IChannelPromise = null):void {
        trace("TEST connect.");
        super.connect(ctx, host, port, promise);
    }

    override public function disconnect(ctx:IChannelHandlerContext, promise:IChannelPromise = null):void {
        trace("TEST disconnect.");
        super.disconnect(ctx, promise);
    }

    override public function close(ctx:IChannelHandlerContext, promise:IChannelPromise = null):void {
        trace("TEST close.");
        super.close(ctx, promise);
    }

    override public function read(ctx:IChannelHandlerContext):void {
        trace("TEST read.");
        super.read(ctx);
    }

    override public function write(ctx:IChannelHandlerContext, msg:*, promise:IChannelPromise = null):void {
        trace("TEST write.");
        super.write(ctx, msg, promise);
    }

    override public function flush(ctx:IChannelHandlerContext):void {
        trace("TEST flush.");
        super.flush(ctx);
    }

}
