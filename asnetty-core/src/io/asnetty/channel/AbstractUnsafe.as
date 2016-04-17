package io.asnetty.channel {

/**
 * @author Jeremy
 */
public class AbstractUnsafe implements IUnsafe {

    /** @private */
    private var _channel:AbstractChannel;

    /**
     * Constructor
     */
    public function AbstractUnsafe(channel:AbstractChannel) {
        super();
        this._channel = channel;
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

    protected virtual function doClose():void {
        // NOOP.
    }

    public function beginRead():void {

    }

    public function write(msg:*, promise:IChannelPromise):void {

    }

    public function flush():void {

    }

}
}
