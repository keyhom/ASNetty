package io.asnetty.channel {

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

}
}
