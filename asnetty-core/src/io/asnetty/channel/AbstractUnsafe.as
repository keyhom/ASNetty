package io.asnetty.channel {

/**
 * @author Jeremy
 */
public class AbstractUnsafe implements IUnsafe {

    protected static const CLOSED_CHANNEL_EXCEPTION:Error = new Error("Write to closed channel.");

    private var _channel:AbstractChannel;
    private var _outboundBuffer:ChannelOutboundBuffer;
    private var _inFlushOut:Boolean;

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
        // NOOP.
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

        if (wasActive && !channel.isActive) {
            _channel.pipeline.fireChannelInactive();
        }

        safeSetSuccess(promise);
        closeIfClosed(); // doDisconnect() might have closed the channel.
    }

    protected function doDisconnect():void {
        // NOOP.
    }

    public final function close(promise:IChannelPromise):void {
        const outboundBuffer:ChannelOutboundBuffer = this._outboundBuffer;
        if (!outboundBuffer) {
            if (promise) {
                // This means close() was called before so we just register a listener and return
                _channel.closeFuture.addEventListener(ChannelFutureEvent.OPERATION_COMPLETE,
                        function (event:ChannelFutureEvent):void {
                            event.future.removeEventListener(ChannelFutureEvent.OPERATION_COMPLETE, arguments.callee);
                            promise.setSuccess();
                        }, false, 0, true);
            }
            return;
        }

        if (_channel.closeFuture.isDone) {
            // Closed already.
            safeSetSuccess(promise);
            return;
        }

        const wasActive:Boolean = _channel.isActive;
        this._outboundBuffer = null; // Disallow adding any messages and flushes to outboundBuffer.
        try {
            // Close the channel and fail the queued messages in all cases.
            doClose();
            _channel.closeFuture.setSuccess();
            safeSetSuccess(promise);
        } catch (e:Error) {
            _channel.closeFuture.setSuccess();
            safeSetFailure(promise, e);
        } finally {
            // Fail all the queued messages.
            outboundBuffer.failFlushed(CLOSED_CHANNEL_EXCEPTION, false);
            outboundBuffer.close(CLOSED_CHANNEL_EXCEPTION);
        }

        if (_inFlushOut) {
            if (wasActive && !_channel.isActive)
                _channel.pipeline.fireChannelInactive();
        }
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

    public final function beginRead():void {
        if (!_channel.isActive)
            return;

        try {
            doBeginRead();
        } catch (e:Error) {
            _channel.pipeline.fireErrorCaught(e);
            close(null);
        }
    }

    protected virtual function doBeginRead():void {
        // NOOP.
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

    [Inline]
    protected static function safeSetFailure(promise:IChannelPromise, cause:Error):void {
        promise && promise.setFailure(cause);
    }

    [Inline]
    protected static function safeSetSuccess(promise:IChannelPromise):void {
        promise && promise.setSuccess();
    }

    protected final function closeIfClosed():void {
        if (channel.isOpen)
            return;
        close(null);
    }

}
}
