package io.asnetty.channel {
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
    private var _unsafe:IUnsafe;

    private var _bActive:Boolean;
    private var _bWritable:Boolean;
    private var _bReadable:Boolean;

    /**
     * Constructor
     */
    public function AbstractChannel(unsafe:IUnsafe) {
        super();

        this._id = ++__INSTANCE_ID;
        this._bActive = false;
        this._bWritable = this._bReadable = false;
        this._unsafe = unsafe;
        this._pipeline = new DefaultChannelPipeline(this);
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

    public function connect(host:String, port:int, timeout:Number = 30):IChannelFuture {
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

}
}

