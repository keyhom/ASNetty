package io.asnetty.channel {

/**
 * @author Jeremy
 */
public class ChannelOutboundBuffer {

    /** @private */
    private var _channel:AbstractChannel;

    /** Constructor */
    public function ChannelOutboundBuffer(channel:AbstractChannel) {
        super();
        this._channel = channel;
    }

    /**
     * Add given message to this <code>ChannelOutboundBuffer</code>. The given
     * <code>IChannelPromise</code> will be notified once the message was
     * written.
     */
    public function addMessage(msg:*, size:int, promise:IChannelPromise):void {
        // TODO: addMessage
    }

    /**
     * Add a flush to this <code>ChannelOutboundBuffer</code>. This meas all
     * previous added messages are marked as flushed and so you will be able to
     * handle them.
     */
    public function addFlush():void {
        // TODO: addFlush
    }

} // class ChannelOutboundBuffer
}
