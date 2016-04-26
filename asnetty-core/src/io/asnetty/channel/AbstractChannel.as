package io.asnetty.channel {

import flash.utils.ByteArray;

/**
 * Abstract implementation of <code>IChannel</code>.
 *
 * @author Jeremy
 */
public class AbstractChannel implements IChannel {

    /** @private */
    static private var __INSTANCE_ID:int = 0;

    private var _id:int;
    private var _pipeline:IChannelPipeline;
    private var _parent:IChannel;
    private var _config:IChannelConfig;
    private var _unsafe:IUnsafe;
    private var _estimatorHandle:IMessageSizeEstimateHandle;

    private var _bActive:Boolean;
    private var _bWritable:Boolean;
    private var _bReadable:Boolean;
    private var _closeFuture:DefaultChannelPromise;

    /**
     * Constructor
     */
    public function AbstractChannel(unsafe:IUnsafe, config:IChannelConfig) {
        super();

        if (!unsafe)
            throw new Error("unsafe can't be null.");

        if (!config)
            throw new Error("config can't be null.");

        this._id = ++__INSTANCE_ID;
        this._bActive = false;
        this._bWritable = this._bReadable = false;
        this._unsafe = unsafe;
        this._config = config;
        this._pipeline = new DefaultChannelPipeline(this);
        this._closeFuture = new DefaultChannelPromise(this);
    }

    public function get id():uint {
        return _id;
    }

    public function get isOpen():Boolean {
        return _bActive;
    }

    public function get parent():IChannel {
        return _parent;
    }

    public function get config():IChannelConfig {
        return _config;
    }

    public function get unsafe():IUnsafe {
        return _unsafe;
    }

    public function get isActive():Boolean {
        return _bActive;
    }

    public function get isWritable():Boolean {
        return _bWritable;
    }

    protected function set writable(value:Boolean):void {
        _bWritable = value;
    }

    public function get isReadable():Boolean {
        return _bReadable;
    }

    protected function set readable(value:Boolean):void {
        _bReadable = value;
    }

    public function get pipeline():IChannelPipeline {
        return _pipeline;
    }

    public function get closeFuture():IChannelPromise {
        return _closeFuture;
    }

    public function connect(host:String, port:int, timeout:Number = 30):IChannelFuture {
        config.connectTimeoutMillis = timeout * 1000;
        return _pipeline.connect(host, port);
    }

    public function disconnect(promise:IChannelPromise = null):IChannelFuture {
        return _pipeline.disconnect(promise);
    }

    public function close(promise:IChannelPromise = null):IChannelFuture {
        return _pipeline.close(promise);
    }

    public function read():IChannel {
        _pipeline.read();
        return this;
    }

    public function write(msg:*, promise:IChannelPromise = null):IChannelFuture {
        return _pipeline.write(msg, promise);
    }

    public function flush():IChannel {
        _pipeline.flush();
        return this;
    }

    public function writeAndFlush(msg:*, promise:IChannelPromise = null):IChannelFuture {
        return _pipeline.writeAndFlush(msg, promise);
    }

    final internal function get estimatorHandle():IMessageSizeEstimateHandle {
        if (!_estimatorHandle) {
            _estimatorHandle = config.messageSizeEstimator.newHandle();
        }
        return _estimatorHandle;
    }

    /** @private internal use only. */
    internal function onWrite(outboundBuffer:ChannelOutboundBuffer):void {
        this.doWrite(outboundBuffer);
    }

    protected function doWrite(outboundBuffer:ChannelOutboundBuffer):void {
        var writeSpinCount:int = -1;
        for (; ;) {
            const current:* = outboundBuffer.current;
            if (!current) {
                // wrote all messages.
                return;
            }


            if (current is ByteArray) {
                var ba:ByteArray = current as ByteArray;
                if (!ba.bytesAvailable) {
                    outboundBuffer.remove();
                    continue;
                }

                if (-1 == writeSpinCount) {
                    writeSpinCount = config.writeSpinCount;
                }

                var done:Boolean = false;
                var flushedAmount:Number = 0;

                for (var i:int = writeSpinCount - 1; i >= 0; i--) {
                    var localFlushedAmount:int = doWriteBytes(ba);
                    if (localFlushedAmount == 0)
                        break;

                    flushedAmount += localFlushedAmount;
                    if (!ba.bytesAvailable) {
                        done = true;
                        break;
                    }
                }

                // outboundBuffer.progress(flushedAmount);

                if (done) {
                    outboundBuffer.remove();
                }
            } else {
                throw new Error("Only ByteArray written is allowed.");
            }
        }

        // incompleteWrite();
    }

    protected function doWriteBytes(bytes:ByteArray):int {
        // NOOP.
        return 0;
    }

//    protected function incompleteWrite():void {
//        // NOOP.
//    }

}
}

