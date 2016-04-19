package io.asnetty.channel {

/**
 * A default <code>IChannelConfig</code> implementaion.
 *
 * @author Jeremy
 */
public class DefaultChannelConfig implements IChannelConfig {

    private var _autoRead:Boolean;
    private var _connectTimeoutMillis:Number;
    private var _msgSizeEstimator:IMessageSizeEstimator;
    private var _writeSpinCount:int;
    private var _writeBufferWaterMark:WriteBufferWaterMark;

    private var _channel:IChannel;

    /** Constructor */
    public function DefaultChannelConfig(channel:IChannel) {
        super();
        this._channel = channel;
        this._msgSizeEstimator = DefaultMessageSizeEstimator.DEFAULT;
        this._autoRead = true;
        this._connectTimeoutMillis = 30000;
        this._writeSpinCount = 1;
        this._writeBufferWaterMark = WriteBufferWaterMark.DEFAULT;
    }

    public function getOptions(...args):Object {
        args = args ||
                [ChannelOptionContants.CONNECT_TIMEOUT_MILLIS,
                    ChannelOptionContants.WRITE_SPIN_COUNT,
                    ChannelOptionContants.AUTO_READ,
                    ChannelOptionContants.WRITE_BUFFER_LOW_MARK,
                    ChannelOptionContants.WRITE_BUFFER_HIGH_MARK,
                    ChannelOptionContants.WRITE_BUFFER_WATER_MARK,
                    ChannelOptionContants.MESSAGE_SIZE_ESTIMATOR];

        const result:Object = {};

        for each (var arg:String in args) {
            result[arg] = getOption(arg);
        }

        return result;
    }

    public function setOptions(options:Object):Boolean {
        var setAllOptions:Boolean = true;
        for (var k:* in options) {
            if (!setOption(k, options[k]))
                setAllOptions = false;
        }
        return setAllOptions;
    }

    public function getOption(key:*):* {
        if (!key)
            throw new Error("key is invalid.");
        if (key == ChannelOptionContants.CONNECT_TIMEOUT_MILLIS)
            return connectTimeoutMillis;
        else if (key == ChannelOptionContants.WRITE_SPIN_COUNT)
            return writeSpinCount;
        else if (key == ChannelOptionContants.AUTO_READ)
            return autoRead;
        else if (key == ChannelOptionContants.WRITE_BUFFER_LOW_MARK)
            return writeBufferLowWaterMark;
        else if (key == ChannelOptionContants.WRITE_BUFFER_HIGH_MARK)
            return writeBufferHighWaterMark;
        else if (key == ChannelOptionContants.WRITE_BUFFER_WATER_MARK)
            return writeBufferWaterMark;
        else if (key == ChannelOptionContants.MESSAGE_SIZE_ESTIMATOR)
            return messageSizeEstimator;
        else
            return null;
    }

    public function setOption(key:*, value:*):Boolean {
        if (key == ChannelOptionContants.CONNECT_TIMEOUT_MILLIS) {
            this._connectTimeoutMillis = Number(value);
        } else if (key == ChannelOptionContants.WRITE_SPIN_COUNT) {
            this._writeSpinCount = int(value);
        } else if (key == ChannelOptionContants.AUTO_READ) {
            this._autoRead = Boolean(value);
        } else if (key == ChannelOptionContants.WRITE_BUFFER_WATER_MARK) {
            this._writeBufferWaterMark = value as WriteBufferWaterMark;
        } else if (key == ChannelOptionContants.MESSAGE_SIZE_ESTIMATOR) {
            this._msgSizeEstimator = value as IMessageSizeEstimator;
        } else if (key == ChannelOptionContants.WRITE_BUFFER_LOW_MARK) {
            this._writeBufferWaterMark = new WriteBufferWaterMark(int(value),
                    this._writeBufferWaterMark.high, false);
        } else if (key == ChannelOptionContants.WRITE_BUFFER_HIGH_MARK) {
            this._writeBufferWaterMark = new
                    WriteBufferWaterMark(this._writeBufferWaterMark.low, int(value),
                    false);
        } else {
            return false;
        }
        return true;
    }

    public function get connectTimeoutMillis():Number {
        return _connectTimeoutMillis;
    }

    public function set connectTimeoutMillis(value:Number):void {
        this._connectTimeoutMillis = value;
    }

    public function get writeSpinCount():int {
        return this._writeSpinCount;
    }

    public function set writeSpinCount(value:int):void {
        this._writeSpinCount = value;
    }

    public function get autoRead():Boolean {
        return _autoRead;
    }

    public function set autoRead(value:Boolean):void {
        this._autoRead = value;
    }

    public function get writeBufferHighWaterMark():int {
        return writeBufferWaterMark.high;
    }

    public function get writeBufferLowWaterMark():int {
        return writeBufferWaterMark.low;
    }

    public function get messageSizeEstimator():IMessageSizeEstimator {
        return this._msgSizeEstimator;
    }

    public function set messageSizeEstimator(value:IMessageSizeEstimator):void {
        this._msgSizeEstimator = value;
    }

    public function get writeBufferWaterMark():WriteBufferWaterMark {
        return _writeBufferWaterMark;
    }

} // class DefaultChannelConfig
}
