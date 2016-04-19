package io.asnetty.channel {
/**
 * @author Jeremy
 */
public class AbstractUnsafe implements IUnsafe {

    private static var CLOSED_CHANNEL_EXCEPTION:Error = new Error("Write to closed channel.");

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

    public final function disconnect(promise:IChannelPromise):void {
        var wasActive:Boolean = channel.isActive;
        try {
            doDisconnect();
        } catch (e:Error) {
            safeSetFailure(promise, e);
            closeIfClosed();
            return;
        }

        if (wasActive && channel.isActive) {

        }

        safeSetSuccess(promise);
        closeIfClosed();
    }

    protected function doDisconnect():void {
        // NOOP.
    }

    public final function close(promise:IChannelPromise):void {

    }

    public final function closeForcibly():void {
        try {
            doClose();
        } catch (e:Error) {
            // Log to failed.
        }
    }

    protected virtual function doClose():void {
        // NOOP.
    }

    public function beginRead():void {

    }

    public function write(msg:*, promise:IChannelPromise):void {
        const outboundBuffer:ChannelOutboundBuffer = this._outboundBuffer;

        if (!outboundBuffer) {
            safeSetFailure(promise, CLOSED_CHANNEL_EXCEPTION);
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
        const outboundBuffer:ChannelOutboundBuffer = this._outboundBuffer;

        if (!outboundBuffer)
            return;

        outboundBuffer.addFlush();
        flushOut();
    }

    private var _inFlushOut:Boolean;

    protected function flushOut():void {
        if (_inFlushOut) {
            // Avoid re-entrance.
            return;
        }

        const outboundBuffer:ChannelOutboundBuffer = this._outboundBuffer;
        if (!outboundBuffer || outboundBuffer.isEmpty)
            return;

        _inFlushOut = true;

        // Mark all pending write requests as failure if the channel is inactive.
        if (!channel.isActive) { // Write to closed channel.
            try {
                outboundBuffer.failFlushed(CLOSED_CHANNEL_EXCEPTION, false);
            } finally {
                _inFlushOut = false;
            }
            return;
        }

        try {
            channel.doWrite(outboundBuffer);
        } catch (e:Error) {
            outboundBuffer.failFlushed(e, true);
        } finally {
            _inFlushOut = false;
        }
    }

    //noinspection JSMethodCanBeStatic
    protected function filteredOutboundMessage(msg:*):* {
        return msg;
    }

    protected static function safeSetFailure(promise:IChannelPromise, cause:Error):void {
        // TODO: safeSetFailure, tryFailure
        promise.setFailure(cause);
    }

    protected static function safeSetSuccess(promise:IChannelPromise):void {
        // TODO: safeSetSuccess, trySuccess
        promise.setSuccess();
    }

    protected final function closeIfClosed():void {
        if (channel.isOpen)
            return;
        close(null);
    }

}
}
