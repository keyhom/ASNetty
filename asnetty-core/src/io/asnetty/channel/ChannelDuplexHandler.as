package io.asnetty.channel {

/**
 * <code>IChannelHandler</code> implementation which represents a combination
 * out of a <code>ChannelInboundHandlerAdapter</code> and the
 * <code>IChannelOutboundHandler</code>.
 *
 * It's a good starting point if your <code>IChannelHandler</code>
 * implementation needs to intercept operations and also state updates.
 *
 * @author Jeremy
 */
public class ChannelDuplexHandler extends ChannelInboundHandlerAdapter
    implements IChannelOutboundHandler {

    /** Constructor */
    public function ChannelDuplexHandler() {
        super();
    }

    public function connect(ctx:IChannelHandlerContext, host:String, port:int,
            promise:IChannelPromise = null):void {
        ctx.makeConnect(host, port, promise);
    }

    public function disconnect(ctx:IChannelHandlerContext,
            promise:IChannelPromise = null):void {
        ctx.makeDisconnect(promise);
    }

    public function close(ctx:IChannelHandlerContext,
            promise:IChannelPromise = null):void {
        ctx.makeClose(promise);
    }

    public function read(ctx:IChannelHandlerContext):void {
        ctx.makeRead();
    }

    public function write(ctx:IChannelHandlerContext, msg:*,
            promise:IChannelPromise = null):void {
        ctx.makeWrite(msg, promise);
    }

    public function flush(ctx:IChannelHandlerContext):void {
        ctx.makeFlush();
    }

} // class ChannelDuplexHandler
}
