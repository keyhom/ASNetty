package io.asnetty.channel {

/**
 * @author Jeremy
 */
public class SocketChannel extends AbstractChannel implements IChannel {

    private var _connectFuture:IChannelFuture;
    private var _closeFuture:IChannelFuture;

    /**
     * Constructs by the specified host and port.
     */
    public function SocketChannel() {
        super(new SocketChannelUnsafe(this));
        _connectFuture = new DefaultChannelPromise(this);
        _closeFuture = new DefaultChannelPromise(this);
    }

    override public function get isOpen():Boolean {
        return (unsafe as SocketChannelUnsafe).isOpen;
    }

    public function get connectFuture():IChannelFuture {
        return _connectFuture;
    }

    public function get closeFuture():IChannelFuture {
        return _closeFuture;
    }

    public function setWritable(value:Boolean):void {
        this.writable = value;
    }

    public function setReadable(value:Boolean):void {
        this.readable = value;
    }

}
}

import flash.errors.IOError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.utils.ByteArray;

import io.asnetty.channel.AbstractUnsafe;
import io.asnetty.channel.ChannelFutureEvent;
import io.asnetty.channel.IChannelFuture;
import io.asnetty.channel.IChannelPromise;
import io.asnetty.channel.SocketChannel;

/**
 *
 * @author Jeremy
 */
class SocketChannelUnsafe extends AbstractUnsafe {

    private var _socket:Socket;

    /**
     * Constructor
     */
    public function SocketChannelUnsafe(channel:SocketChannel) {
        super(channel);
    }

    public function get isOpen():Boolean {
        return _socket && _socket.connected;
    }

    protected function get ch():SocketChannel {
        return channel as SocketChannel;
    }

    override public function connect(host:String, port:int, promise:IChannelPromise):void {
        doConnect(host, port);
    }

    protected function doConnect(host:String, port:int):IChannelFuture {
        _socket = _socket || new Socket();
        var timeout:uint = 30; // TODO: Get from the config or attribute.
        _socket.timeout = timeout * 1000;

        _socket.addEventListener(Event.CONNECT, _socket_connectOperationComplete);

        _socket.addEventListener(ProgressEvent.SOCKET_DATA, _socket_dataEventHandler);
        _socket.addEventListener(IOErrorEvent.IO_ERROR, _socket_ioErrorEventHandler);
        _socket.addEventListener(Event.CLOSE, _socket_closeEventHandler);
        _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _socket_securityErrorEventHandler);

        _socket.connect(host, port);

        return ch.connectFuture;
    }

    /** @private EventHandler */
    private function _socket_securityErrorEventHandler(event:SecurityErrorEvent):void {
        // Security | timeout error.
        var error:Error = new SecurityError((event as SecurityErrorEvent).text, (event as SecurityErrorEvent).errorID);
        channel.pipeline.fireErrorCaught(error);
    }

    /** @private EventHandler */
    private function _socket_connectOperationComplete(event:Event):void {
        _socket.removeEventListener(Event.CONNECT, _socket_connectOperationComplete);

        var eventData:* = ch;

        if (_socket.connected) {
            _socket.flush();
            // Notify channel active during pipeline.
            channel.pipeline.fireChannelActive();

            // Mark free w.
            ch.setWritable(true);
        }

        ch.connectFuture.dispatchEvent(new ChannelFutureEvent(eventData));
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
        channel.pipeline.fireErrorCaught(new IOError(event.text, event.errorID));
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

        ch.setReadable(true);
        channel.pipeline.fireChannelRead(bytes);
    }

}
