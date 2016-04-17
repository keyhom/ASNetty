package io.asnetty.channel {

import io.asnetty.handler.IChannelHandlerContext;

/**
 * @author Jeremy
 */
public class ChannelInitializer extends ChannelHandlerAdapter {

    /**
     * Constructor
     */
    public function ChannelInitializer(initFn:Function = null) {
        super();
        this._initFn = initFn;
    }

    /** @private */
    private var _initFn:Function;

    public function get initChannel():Function {
        if (null == _initFn) {
            _initFn = function (ch:IChannel):void {
                // NOOP.
            }
        }

        return _initFn;
    }

    public function set initChannel(value:Function):void {
        this._initFn = value;
    }

    override public function channelActive(ctx:IChannelHandlerContext):void {
        initChannel(ctx.channel);
        ctx.pipeline.remove(this);
        ctx.fireChannelActive();
    }

    override public function errorCaught(ctx:IChannelHandlerContext, cause:Error):void {
        try {
            const pipeline:IChannelPipeline = ctx.pipeline;
            if (pipeline.context(this)) {
                pipeline.remove(this);
            }
        } finally {
            ctx.makeClose();
        }
    }

} // class ChannelInitializer
}
