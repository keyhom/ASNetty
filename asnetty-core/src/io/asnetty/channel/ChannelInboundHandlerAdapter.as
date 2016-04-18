package io.asnetty.channel {
/**
 * @author Jeremy
 */
public class ChannelInboundHandlerAdapter extends ChannelHandlerAdapter implements IChannelInboundHandler {

    /**
     * Constructor
     */
    public function ChannelInboundHandlerAdapter() {
        super();
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


}
}
