package io.asnetty.channel {

/**
 * @author Jeremy
 */
public class AbstractUnsafe implements IUnsafe {

    private static var CLOSED_CHANNEL_EXCEPTION:Error = new Error("Write to closed channel.");

    /** @private */
    private var _channel:AbstractChannel;
    private var _outboundBuffer:ChannelOutboundBuffer;

    /**
     * Constructor
     */
    public function AbstractUnsafe(channel:AbstractChannel) {
        super();
        this._channel = channel;
        this._outboundBuffer = new ChannelOutboundBuffer(channel);
    }

    public function get outboundBuffer():ChannelOutboundBuffer {
        return _outboundBuffer;
    }

    public function get channel():AbstractChannel {
        return _channel;
    }

    public function connect(host:String, port:int, promise:IChannelPromise):void {

    }

    public function disconnect(promise:IChannelPromise):void {

    }

    public function close(promise:IChannelPromise):void {

    }

    public function closeForcibly():void {
        try {
            doClose();
        } catch (e:Error) {
            // Log to failed.
        }
    }

    protected function doClose():void {
        // NOOP.
    }

    public function beginRead():void {

    }

    public function write(msg:*, promise:IChannelPromise):void {
        const outboundBuffer:ChannelOutboundBuffer = this._outboundBuffer;

        if (!outboundBuffer) {
            this.safeSetFailure(promise, CLOSED_CHANNEL_EXCEPTION);
            return;
        }

        var size:int = 0;

        try {
            msg = this.filteredOutboundMessage(msg);
            size = channel.estimatorHandle.size(msg);
        } catch (e:Error) {
            safeSetFailure(promise, e);
            return;
        }

        outboundBuffer.addMessage(msg, size, promise);
    }

    public function flush():void {

    }

    protected function filteredOutboundMessage(msg:*):* {
        return msg;
    }

    protected function safeSetFailure(promise:IChannelPromise, cause:Error):void {
        // TODO: safeSetFailure
    }

    protected function safeSetSuccess(promise:IChannelPromise):void {
        // TODO: safeSetSuccess
    }

}
}
