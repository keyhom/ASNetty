package {

import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;

import io.asnetty.bootstrap.Bootstrap;
import io.asnetty.channel.ChannelFutureEvent;
import io.asnetty.channel.IChannelFuture;
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
        var bs : Bootstrap = new Bootstrap();

        var f:IChannelFuture = bs.channel(SocketChannel ).connect("www.baidu.com", 80);
        f.addEventListener(ChannelFutureEvent.OPERATION_COMPLETE, function(event:ChannelFutureEvent):void {
            trace("Operation Completed.");
        }, false, 0, true);
    }

}
}
