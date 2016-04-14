package io.asnetty.channel {

import flash.errors.IOError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.utils.ByteArray;

/**
 * @author Jeremy
 */
public class SocketChannel implements IChannel {

    static private var __INSTANCE_ID:int = 0;

    private var _socket:Socket;
    private var _connectFuture:IChannelFuture;
    private var _closeFuture:IChannelFuture;

    private var _pipeline:IChannelPipeline;
    private var _id:int;
    private var _parent:IChannel;

    private var _bActive:Boolean;
    private var _bWritable:Boolean;
    private var _bReadable:Boolean;

    /**
     * Constructs by the specified host and port.
     */
    public function SocketChannel() {
        super();
        this._id = ++__INSTANCE_ID;
        this._bActive = false;
        this._bWritable = this._bReadable = false;
    }

    public function get id():uint {
        return _id;
    }

    public function get parent():IChannel {
        return _parent;
    }

    public function get isOpen():Boolean {
        return _socket && _socket.connected;
    }

    public function get isActive():Boolean {
        return _bActive;
    }

    public function get isWritable():Boolean {
        return _bWritable;
    }

    public function get isReadable():Boolean {
        return _bReadable;
    }

    public function get pipeline():IChannelPipeline {
        return _pipeline;
    }

    public function connect(host:String, port:int, timeout:Number = 30):IChannelFuture {
        _socket = _socket || new Socket();
        _socket.timeout = timeout * 1000;

        _socket.addEventListener(Event.CONNECT, _socket_connectOperationComplete);

        _socket.addEventListener(ProgressEvent.SOCKET_DATA, _socket_dataEventHandler);
        _socket.addEventListener(IOErrorEvent.IO_ERROR, _socket_ioErrorEventHandler);
        _socket.addEventListener(Event.CLOSE, _socket_closeEventHandler);
        _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _socket_securityErrorEventHandler);

        _connectFuture = _connectFuture || new DefaultChannelPromise(this);
        _pipeline = _pipeline || new DefaultChannelPipeline(this);

        _socket.connect(host, port);

        return _connectFuture;
    }

    /** @private EventHandler */
    private function _socket_securityErrorEventHandler(event:SecurityErrorEvent):void {
        // Security | timeout error.
        var error:Error = new SecurityError((event as SecurityErrorEvent).text, (event as SecurityErrorEvent).errorID);
        _pipeline.fireErrorCaught(error);
    }

    /** @private EventHandler */
    private function _socket_connectOperationComplete(event:Event):void {
        _socket.removeEventListener(Event.CONNECT, _socket_connectOperationComplete);

        var eventData:* = _connectFuture.channel;

        if (_socket.connected) {
            _socket.flush();
            // Notify channel active during pipeline.
            _pipeline.fireChannelActive();

            // Mark free w.
            _bWritable = true;

            // FIXME(Test):
            _socket.writeUTFBytes("<policy-file-request/>");
            _socket.flush();
        }

        _connectFuture.dispatchEvent(new ChannelFutureEvent(eventData));
    }

    /** @private EventHandler */
    private function _socket_closeEventHandler(event:Event):void {
        var theSocket:Socket = _socket || event.currentTarget as Socket;
        theSocket.removeEventListener(Event.CLOSE, _socket_closeEventHandler);
        theSocket.removeEventListener(ProgressEvent.SOCKET_DATA, _socket_dataEventHandler);
        theSocket.removeEventListener(IOErrorEvent.IO_ERROR, _socket_ioErrorEventHandler);
        theSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _socket_securityErrorEventHandler);

        // TODO: force to shutdown the channel.
    }

    /** @private EventHandler */
    private function _socket_ioErrorEventHandler(event:IOErrorEvent):void {
        _pipeline.fireErrorCaught(new IOError(event.text, event.errorID));
    }

    /** @private EventHandler */
    private function _socket_dataEventHandler(event:ProgressEvent):void {
        // data recv.
        if (!_socket.connected || !_socket.bytesAvailable) {
            return;
        }

        var bytes:ByteArray = new ByteArray();
        _socket.readBytes(bytes, 0, _socket.bytesAvailable);
        bytes.position = 0;

        _bReadable = true;
        _pipeline.fireChannelRead(bytes);
    }

    public function disconnect(promise:IChannelPromise = null):IChannelFuture {
        return null;
    }

    public function close(promise:IChannelPromise = null):IChannelFuture {
        _socket.close();
        return _closeFuture;
    }

    public function read():IChannel {
        return null;
    }

    public function write(msg:*, promise:IChannelPromise = null):IChannelFuture {
        return null;
    }

    public function flush():IChannel {
        if (_socket)
            _socket.flush();
        return this;
    }

    public function writeAndFlush(msg:*, promise:IChannelPromise = null):IChannelFuture {
        return null;
    }

}
}
