package io.asnetty.channel {
import flash.net.Socket;
import flash.utils.ByteArray;

/**
 * @author Jeremy
 */
public class SocketChannel extends AbstractChannel implements IChannel {

    private var _connectFuture:IChannelFuture;
    private var _socket:Socket;

    /**
     * Constructs by the specified host and port.
     */
    public function SocketChannel() {
        super(new SocketChannelUnsafe(this), new DefaultChannelConfig(this));
        _connectFuture = new DefaultChannelPromise(this);
        _socket = new Socket();
    }

    public function get socket():Socket {
        return _socket;
    }

    override public function get isActive():Boolean {
        return _socket && _socket.connected;
    }

    override public function get isOpen():Boolean {
        return (unsafe as SocketChannelUnsafe).isOpen;
    }

    public function get connectFuture():IChannelFuture {
        return _connectFuture;
    }

    public function setWritable(value:Boolean):void {
        this.writable = value;
    }

    public function setReadable(value:Boolean):void {
        this.readable = value;
    }

    override internal function doWrite(outboundBuffer:ChannelOutboundBuffer):void {
        super.doWrite(outboundBuffer);

        const current:* = outboundBuffer.current;
        if (current is ByteArray) {
            const ba:ByteArray = current as ByteArray;
            _socket.writeBytes(ba);
        } else if (current is String) {
            const str:String = String(current);
            _socket.writeUTFBytes(str);
        } else {
            // Unknown how to write it.
        }
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
import io.asnetty.channel.IChannelConfig;
import io.asnetty.channel.IChannelPipeline;
import io.asnetty.channel.IChannelPromise;
import io.asnetty.channel.SocketChannel;

/**
 *
 * @author Jeremy
 */
class SocketChannelUnsafe extends AbstractUnsafe {

    /**
     * Constructor
     */
    public function SocketChannelUnsafe(channel:SocketChannel) {
        super(channel);
    }

    [Inline]
    public function get socket():Socket {
        return ch.socket;
    }

    public function get isOpen():Boolean {
        return socket && socket.connected;
    }

    [Inline]
    protected function get ch():SocketChannel {
        return channel as SocketChannel;
    }

    override public function connect(host:String, port:int, promise:IChannelPromise):void {
        doConnect(host, port, promise);
    }

    protected function doConnect(host:String, port:int, promise:IChannelPromise):void {
        const _socket:Socket = this.socket;
        _socket.timeout = channel.config.connectTimeoutMillis;

        _socket.addEventListener(Event.CONNECT, _socket_connectOperationComplete);

        _socket.addEventListener(ProgressEvent.SOCKET_DATA, _socket_dataEventHandler);
        _socket.addEventListener(IOErrorEvent.IO_ERROR, _socket_ioErrorEventHandler);
        _socket.addEventListener(Event.CLOSE, _socket_closeEventHandler);
        _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _socket_securityErrorEventHandler);

        _socket.connect(host, port);

        /** @private EventHandler */
        function _socket_connectOperationComplete(event:Event):void {
            _socket.removeEventListener(Event.CONNECT, _socket_connectOperationComplete);

            if (_socket.connected) {
                // Notify channel active during pipeline.
                channel.pipeline.fireChannelActive();

                // Mark free w.
                ch.setWritable(true);
                _socket.flush();
            }

            promise.trySuccess();
        }
    }

    override protected function doDisconnect():void {
        super.doDisconnect();
        doClose();
    }

    override protected function doClose():void {
        super.doClose();
        if (ch.connectFuture is IChannelPromise) {
            (ch.connectFuture as IChannelPromise).tryFailure(CLOSED_CHANNEL_EXCEPTION);
        }
        socket.close();
        socket.dispatchEvent(new Event(Event.CLOSE));
    }

    /** @private EventHandler */
    private function _socket_securityErrorEventHandler(event:SecurityErrorEvent):void {
        // Security | timeout error.
        var error:Error = new SecurityError((event as SecurityErrorEvent).text, (event as SecurityErrorEvent).errorID);
        channel.pipeline.fireErrorCaught(error);
    }

    /** @private EventHandler */
    private function _socket_closeEventHandler(event:Event):void {
        var theSocket:Socket = socket || event.currentTarget as Socket;
        theSocket.removeEventListener(Event.CLOSE, _socket_closeEventHandler);
        theSocket.removeEventListener(ProgressEvent.SOCKET_DATA, _socket_dataEventHandler);
        theSocket.removeEventListener(IOErrorEvent.IO_ERROR, _socket_ioErrorEventHandler);
        theSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _socket_securityErrorEventHandler);

        channel.close();
    }

    /** @private EventHandler */
    private function _socket_ioErrorEventHandler(event:IOErrorEvent):void {
        channel.pipeline.fireErrorCaught(new IOError(event.text, event.errorID));
    }

    /** @private EventHandler */
    private function _socket_dataEventHandler(event:ProgressEvent):void {
        // data recv.
        if (!socket.connected || !socket.bytesAvailable) {
            return;
        }

        var bytes:ByteArray = new ByteArray();
        socket.readBytes(bytes, 0, socket.bytesAvailable);
        bytes.position = 0;

        ch.setReadable(true);

        const config:IChannelConfig = channel.config;
        if (!config.autoRead)
            return;

        const pipeline:IChannelPipeline = channel.pipeline;

        pipeline.fireChannelRead(bytes);
        pipeline.fireChannelReadComplete();
    }

}
