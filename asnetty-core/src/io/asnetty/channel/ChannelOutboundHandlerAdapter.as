package io.asnetty.channel {

/**
 * @author Jeremy
 */
public class ChannelOutboundHandlerAdapter extends ChannelHandlerAdapter implements IChannelOutboundHandler {

    /**
     * Constructor
     */
    public function ChannelOutboundHandlerAdapter() {
        super();
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
