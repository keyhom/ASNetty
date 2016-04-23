package {

import flash.display.Sprite;
import flash.events.Event;

import io.asnetty.bootstrap.Bootstrap;
import io.asnetty.channel.ChannelFutureEvent;
import io.asnetty.channel.ChannelInitializer;
import io.asnetty.channel.IChannel;
import io.asnetty.channel.IChannelFuture;
import io.asnetty.channel.IChannelPipeline;
import io.asnetty.channel.SocketChannel;
import io.asnetty.handler.codec.LengthFieldBasedFrameDecoder;
import io.asnetty.handler.codec.LengthFieldPrepender;
import io.asnetty.handler.codec.string.StringDecoder;
import io.asnetty.handler.codec.string.StringEncoder;
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

//            pipeline.addLast("LengthFieldPrepender", new LengthFieldPrepender(2));
            pipeline.addLast("StringEncoder", new StringEncoder);

            // pipeline.addLast("LengthFieldFrameDecoder", new LengthFieldBasedFrameDecoder(1048576, 0, 2, 0, 2));
            pipeline.addLast("StringDecoder", new StringDecoder);

            pipeline.addLast("LoggingHandler", new LoggingHandler());
            // pipeline.addLast("TestHandler", new TestChannelHandler());

        })).connect("localhost", 9090, 2);

        f.addEventListener(ChannelFutureEvent.OPERATION_COMPLETE, function (event:ChannelFutureEvent):void {
            f.removeEventListener(ChannelFutureEvent.OPERATION_COMPLETE, arguments.callee);
            trace("Operation Completed.");

            if (f.isSuccess) {
                trace("Connected successfuly.");
//                var str:String = "GET / HTTP/1.1\r\n";
//                str += "Host: localhost\r\n";
//                str += "Connection: Keep-Alive\r\n";
//                f.channel.writeAndFlush(str);
                var str:String = "<policy-file-request/>";
                f.channel.writeAndFlush(str);
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
