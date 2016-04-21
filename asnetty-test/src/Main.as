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
import io.asnetty.handler.logging.LoggingHandler;

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

            pipeline.addLast("LoggingHandler", new LoggingHandler());
            pipeline.addLast("TestHandler", new TestChannelHandler());

        })).connect("www.qifun.com", 80, 2);

        f.addEventListener(ChannelFutureEvent.OPERATION_COMPLETE, function (event:ChannelFutureEvent):void {
            f.removeEventListener(ChannelFutureEvent.OPERATION_COMPLETE, arguments.callee);
            trace("Operation Completed.");

            if (f.isSuccess) {
                trace("Connected successfuly.");
                var bs:ByteArray = new ByteArray();
                var str:String = "GET / HTTP/1.1\r\n";
                str += "Host: localhost\r\n";
                str += "Connection: Keep-Alive\r\n";
                bs.writeUTFBytes(str + "\r\n");
                f.channel.writeAndFlush(bs);
            } else {
                trace("Connected failed: ", f.cause.toString());
            }
        });
    }

}
}

import io.asnetty.channel.ChannelDuplexHandler;
import io.asnetty.channel.IChannelHandlerContext;

class TestChannelHandler extends ChannelDuplexHandler {

    function TestChannelHandler() {
        super();
    }

    override public function channelReadComplete(ctx:IChannelHandlerContext):void {
        ctx.fireChannelReadComplete();
        ctx.makeClose();
    }

}
