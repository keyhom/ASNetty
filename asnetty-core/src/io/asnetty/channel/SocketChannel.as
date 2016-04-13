package io.asnetty.channel {

import flash.errors.EOFError;
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

        _socket.addEventListener(Event.CONNECT, _socket_operationComplete, false, 0, true);
        _socket.addEventListener(Event.CLOSE, _socket_operationComplete, false, 0, true);
        _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _socket_operationComplete, false, 0, true);

        _socket.addEventListener(ProgressEvent.SOCKET_DATA, _socket_dataEventHandler, false);
        _socket.addEventListener(IOErrorEvent.IO_ERROR, _socket_ioErrorEventHandler, false, 0, true);
        _socket.addEventListener(Event.CLOSE, _socket_closeEventHandler, false, 0, true);

        _connectFuture = _connectFuture || new DefaultChannelPromise(this);
        _pipeline = _pipeline || new DefaultChannelPipeline(this);

        _socket.connect(host, port);

        function _socket_operationComplete(event:Event):void {
            _socket.removeEventListener(Event.CONNECT, _socket_operationComplete);
            _socket.removeEventListener(Event.CLOSE, _socket_operationComplete);
            _socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _socket_operationComplete);

            var eventData:*;
            if (event.type == Event.CONNECT) {
                // Connected.
                eventData = _connectFuture.channel;

                if (_socket.connected) {
                    // Notify channel active during pipeline.
                    _pipeline.fireChannelActive();

                    // Mark free w.
                    _bWritable = true;
                }
            } else if (event.type == Event.CLOSE) {
                // EOF error.
                eventData = new EOFError("Closed by EOF.");
            } else if (event.type == SecurityErrorEvent.SECURITY_ERROR) {
                // Security | timeout error.
                eventData = new SecurityError((event as SecurityErrorEvent).text, (event as SecurityErrorEvent).errorID);
            }

            _connectFuture.dispatchEvent(new ChannelFutureEvent(eventData));

            if (eventData is Error) {
                _pipeline.fireErrorCaught(eventData as Error);
            }
        }

        return _connectFuture;
    }

    /** @private EventHandler */
    private function _socket_closeEventHandler(event:Event):void {
        var theSocket:Socket = _socket || event.currentTarget as Socket;
        theSocket.removeEventListener(Event.CLOSE, _socket_closeEventHandler);
        theSocket.removeEventListener(ProgressEvent.SOCKET_DATA, _socket_dataEventHandler);
        theSocket.removeEventListener(IOErrorEvent.IO_ERROR, _socket_ioErrorEventHandler);

        // TODO: force to shutdown the channel.
    }

    /** @private EventHandler */
    private function _socket_ioErrorEventHandler(event:IOErrorEvent):void {
        _pipeline.fireErrorCaught(new IOError(event.text, event.errorID));
    }

    /** @private EventHandler */
    private function _socket_dataEventHandler(event:ProgressEvent):void {
        // data recv.
        var bytes:ByteArray = new ByteArray();
        _socket.readBytes(bytes, 0, _socket.bytesAvailable);

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
        return null;
    }

    public function writeAndFlush(msg:*, promise:IChannelPromise = null):IChannelFuture {
        return null;
    }

}
}
