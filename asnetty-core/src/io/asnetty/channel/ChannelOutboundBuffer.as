package io.asnetty.channel {

import flash.utils.ByteArray;

/**
 * @author Jeremy
 */
public class ChannelOutboundBuffer {

    /** @private */
    private static function total(msg:*):int {
        if (msg is ByteArray) {
            return (msg as ByteArray).bytesAvailable;
        } else if (msg is String) {
            return (msg as String).length;
        } else
            return 0;
    }

    /** @private */
    private var _channel:AbstractChannel;

    private var _flushedEntry:OutboundEntry;
    private var _unflushedEntry:OutboundEntry;
    private var _tailEntry:OutboundEntry;
    private var _flushed:int;
    private var _bufferCount:int;
    private var _bufferSize:Number;
    private var _inFail:Boolean;

    private var _totalPendingSize:Number;
    private var _unwritable:int;

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
        const entry:OutboundEntry = OutboundEntry.getInstance(msg, size,
                total(msg), promise);
        if (!_tailEntry) {
            _flushedEntry = null;
            _tailEntry = entry;
        } else {
            const tail:OutboundEntry = _tailEntry;
            tail.next = entry;
            _tailEntry = entry;
        }

        if (!_unflushedEntry) {
            _unflushedEntry = entry;
        }

        incrementPendingOutboundBytes(size);
    }

    /**
     * Add a flush to this <code>ChannelOutboundBuffer</code>. This meas all
     * previous added messages are marked as flushed and so you will be able to
     * handle them.
     */
    public function addFlush():void {
        var entry:OutboundEntry = _unflushedEntry;
        if (entry) {
            if (!_flushedEntry) {
                _flushedEntry = entry;
            }

            do {
                _flushed++;

                // TODO: handle cancelled.
//                if (!entry.promise.setUncancellable()) {
//                    const pending:int = entry.cancel();
//                    decrementPendingOutboundBytes(pending, true);
//                }

                entry = entry.next;
            } while (entry);

            // All flushed so reset unflushedEntry.
            _unflushedEntry = null;
        }
    }

    /** Returns the number of the flushed messages. */
    public function get size():int {
        return _flushed;
    }

    public function get isEmpty():Boolean {
        return _flushed == 0;
    }

    public function get totalPendingWriteBytes():Number {
        return _totalPendingSize;
    }

    public function get bytesBeforeWritable():Number {
        const numBytes:Number = _totalPendingSize - _channel.config.writeBufferLowWaterMark;
        if (numBytes > 0) {
            return isWritable ? 0 : numBytes;
        }
        return 0;
    }

    public function get isWritable():Boolean {
        return _unwritable == 0;
    }

    public function get current():* {
        const entry:OutboundEntry = this._flushedEntry;
        if (!entry)
            return null;
        return entry.msg;
    }

    /**
     * Will remove the current message, mark its <code>IChannelPromise</code> as success and return <code>true</code>.
     * If no flushed message exists at the time this method is called it will return <code>false</code> to signal that
     * no more messages are ready to be handled.
     */
    public function remove(cause:Error = null, notify:Boolean = true):Boolean {
        const e:OutboundEntry = _flushedEntry;
        if (!e) {
            // clear bytes ?
            return false;
        }

        const msg:* = e.msg;
        const promise:IChannelPromise = e.promise;
        const size:Number = e.pendingSize;

        removeEntry(e);

        if (!e.cancelled) {

            if (cause)
                safeFailure(promise, cause);
            else
                safeSuccess(promise);

            decrementPendingOutboundBytes(size, notify);
        }

        // recycle the entry.
        e.recycle();

        return true;
    }

    private function removeEntry(e:OutboundEntry):void {
        if (--_flushed == 0) {
            // processed everything.
            _flushedEntry = null;
            if (e == _tailEntry) {
                _tailEntry = null;
                _unflushedEntry = null;
            }
        } else {
            _flushedEntry = e.next;
        }
    }

    private static function safeSuccess(promise:IChannelPromise):void {
        // TODO: trySuccess.
        promise.setSuccess();
    }

    private static function safeFailure(promise:IChannelPromise, cause:Error):void {
        // TODO: tryFailure.
        promise.setFailure(cause);
    }

    private function incrementPendingOutboundBytes(size:Number):void {
        if (0 == size || isNaN(size))
            return;

        _totalPendingSize += size;

        if (_totalPendingSize >= _channel.config.writeBufferHighWaterMark) {
            this.setUnWritable();
        }
    }

    private function decrementPendingOutboundBytes(size:Number, notifyWritability:Boolean = true):void {
        if (0 == size || isNaN(size))
            return;

        _totalPendingSize -= size;
        if (notifyWritability && (_totalPendingSize == 0 ||
                _totalPendingSize <= _channel.config.writeBufferLowWaterMark)) {
            setUnWritable();
        }
    }

    private function setUnWritable():void {
        for (; ;) {
            const oldValue:int = _unwritable;
            const newValue:int = oldValue | 1;

            if (oldValue != newValue) {
                _unwritable = newValue;

                if (oldValue == 0 && newValue != 0) {
                    fireChannelWritabilityChanged();
                }
                break;
            }
        }
    }

    private function fireChannelWritabilityChanged():void {
        const pipeline:IChannelPipeline = _channel.pipeline;
        pipeline.fireChannelWritabilityChanged();
    }

    internal function failFlushed(cause:Error, notify:Boolean):void {
        if (_inFail) {
            return;
        }

        try {
            _inFail = true;
            for (; ;) {
                if (!remove(cause, notify)) {
                    break;
                }
            }
        } finally {
            _inFail = false;
        }
    }

    internal function close(cause:Error):void {
        if (_inFail)
            return;

        _inFail = true;

        if (_channel.isOpen) {
            throw new Error("close() must be invoked after the channel is closed.");
        }

        if (!isEmpty) {
            throw new Error("close() must be invoked after all the flushed writes are handled.");
        }

        // Release all unflushed message.
        try {
            var e:OutboundEntry = _unflushedEntry;
            while (e) {
                // Just decrease; do not trigger any events via decrementPendingOutboundBytes().
                var size:int = e.pendingSize;
                _totalPendingSize -= size;

                if (!e.cancelled) {
                    safeFailure(e.promise, cause);
                }

                e = e.recycleAndGetNext();
            }
        } finally {
            _inFail = false;
        }
    }

} // class ChannelOutboundBuffer
}

import io.asnetty.channel.IChannelPromise;

/**
 * @author Jeremy
 */
final class OutboundEntry {

    /** @private */
    private static var _entries:Vector.<OutboundEntry>;

    public static function getInstance(msg:*, size:int, total:Number, promise:IChannelPromise):OutboundEntry {
        if (!_entries) {
            _entries = new <OutboundEntry>[];
        }

        var ret:OutboundEntry;

        if (_entries.length > 0)
            ret = _entries.pop();
        else
            ret = new OutboundEntry();

        ret.msg = msg;
        ret.pendingSize = size;
        ret.total = total;
        ret.promise = promise;

        return ret;
    }

    public var next:OutboundEntry;
    public var msg:*;
    public var promise:IChannelPromise;
    public var progress:Number;
    public var total:Number;
    public var pendingSize:int;
    public var count:int = -1;
    public var cancelled:Boolean;

    /** Constructor */
    public function OutboundEntry() {
        super();
        this._reset();
    }

    public function cancel():int {
        if (!cancelled) {
            cancelled = true;
            var pSize:int = pendingSize;

            // release message and replace with an empty buffer.
            msg = null;

            pendingSize = 0;
            total = 0;
            progress = 0;

            return pSize;
        }
        return 0;
    }

    public function recycle():void {
        this._reset();

        if (!_entries) {
            _entries = new <OutboundEntry>[];
        }

        _entries.push(this);
    }

    private function _reset():void {
        this.next = null;
        this.msg = null;
        this.promise = null;
        this.progress = 0;
        this.total = 0;
        this.pendingSize = 0;
        this.count = -1;
        this.cancelled = false;
    }

    public function recycleAndGetNext():OutboundEntry {
        const next:OutboundEntry = this.next;
        this.recycle();
        return next;
    }

}

