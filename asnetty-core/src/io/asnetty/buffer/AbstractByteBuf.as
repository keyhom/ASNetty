package io.asnetty.buffer {
import flash.utils.ByteArray;

/**
 * A skeletal implementation of a buffer.
 *
 * @author Jeremy
 */
public class AbstractByteBuf implements IByteBuf {

    internal var _readerIndex:int;
    internal var _writerIndex:int;

    private var _markedReaderIndex:int;
    private var _markedWriterIndex:int;

    private var _maxCapacity:int;
    private var _endian:String;

    /**
     * Creates an AbstractByteBuf instance.
     */
    public function AbstractByteBuf(maxCapacity:int = 0) {
        super();
        if (maxCapacity < 0) {
            throw new ArgumentError("maxCapacity: " + maxCapacity + " (expected:)>= 0");
        }
        this._maxCapacity = maxCapacity;
    }

    /**
     * @inheritDoc
     */
    public function get capacity():int {
        return 0;
    }

    /**
     * @inheritDoc
     */
    public function set capacity(value:int):void {
        // NOOP.
    }

    /**
     * @inheritDoc
     */
    public function get maxCapacity():int {
        return _maxCapacity;
    }

    /**
     * @private
     */
    public final function set maxCapacity(value:int):void {
        this._maxCapacity = value;
    }

    /**
     * @inheritDoc
     */
    public function get readerIndex():int {
        return _readerIndex;
    }

    /**
     * @inheritDoc
     */
    public function set readerIndex(value:int):void {
        if (value < 0 || value > _writerIndex)
            throw new ArgumentError("readerIndex: " + value + " (expected: 0 <= "
                    + "readerIndex <= writerIndex(" + _writerIndex + "))");
        this._readerIndex = value;
    }

    /**
     * @inheritDoc
     */
    public function get writerIndex():int {
        return _writerIndex;
    }

    /**
     * @inheritDoc
     */
    public function set writerIndex(value:int):void {
        if (value < _readerIndex || value > capacity) {
            throw new ArgumentError("writerIndex: " + value + " (expected: " +
                    "readerIndex (" + _readerIndex + ") <= writerIndex <= capacity" +
                    "(" + capacity + "))");
        }
        this._writerIndex = value;
    }

    /**
     * @inheritDoc
     */
    public function setIndex(readerIndex:int, writerIndex:int):IByteBuf {
        if (readerIndex < 0 || readerIndex > writerIndex || writerIndex >
                capacity) {
            throw new ArgumentError("readerIndex: " + readerIndex +
                    ", writerIndex: " + writerIndex + " (expected: 0 <= " +
                    "readerIndex <= writerIndex <= capacity(" + capacity + "))");
        }
        this._readerIndex = readerIndex;
        this._writerIndex = writerIndex;
        return this;
    }

    /**
     * @inheritDoc
     */
    public function clear():IByteBuf {
        _readerIndex = _writerIndex = 0;
        return this;
    }

    /**
     * @inheritDoc
     */
    public function isReadable(numBytes:int = 0):Boolean {
        numBytes = numBytes > 0 ? numBytes : 1;
        return _writerIndex - _readerIndex >= numBytes;
    }

    /**
     * @inheritDoc
     */
    public function isWritable(numBytes:int = 0):Boolean {
        numBytes = numBytes > 0 ? numBytes : 1;
        return capacity - _writerIndex >= numBytes;
    }

    /**
     * @inheritDoc
     */
    public function get readableBytes():int {
        return _writerIndex - _readerIndex;
    }

    /**
     * @inheritDoc
     */
    public function get writableBytes():int {
        return capacity - _writerIndex;
    }

    /**
     * @inheritDoc
     */
    public function get maxWritableBytes():int {
        return _maxCapacity - _writerIndex;
    }

    /**
     * @inheritDoc
     */
    public function markReaderIndex():IByteBuf {
        _markedReaderIndex = _readerIndex;
        return this;
    }

    /**
     * @inheritDoc
     */
    public function resetReaderIndex():IByteBuf {
        readerIndex = _markedReaderIndex;
        return this;
    }

    /**
     * @inheritDoc
     */
    public function markWriterIndex():IByteBuf {
        _markedWriterIndex = _writerIndex;
        return this;
    }

    /**
     * @inheritDoc
     */
    public function resetWriterIndex():IByteBuf {
        writerIndex = _markedWriterIndex;
        return this;
    }

    /**
     * @inheritDoc
     */
    public function discardReadBytes():IByteBuf {
        if (_readerIndex == 0)
            return this;

        if (_readerIndex != _writerIndex) {
            setBytes(0, this, _readerIndex, _writerIndex - _readerIndex);
            _writerIndex -= _readerIndex;
            adjustMarkers(_readerIndex);
            _readerIndex = 0;
        } else {
            adjustMarkers(_readerIndex);
            _writerIndex = _readerIndex = 0;
        }
        return this;
    }

    /**
     * @inheritDoc
     */
    public function discardSomeReadBytes():IByteBuf {
        if (_readerIndex == 0) {
            return this;
        }

        if (_readerIndex == _writerIndex) {
            adjustMarkers(_readerIndex);
            _writerIndex = _readerIndex = 0;
            return this;
        }

        if (_readerIndex >= (capacity >>> 1)) {
            setBytes(0, this, _readerIndex, _writerIndex - _readerIndex);
            _writerIndex -= _readerIndex;
            adjustMarkers(_readerIndex);
            _readerIndex = 0;
        }
        return this;
    }

    /** @protected */
    protected final function adjustMarkers(decrement:int):void {
        const markedReaderIndex:int = this._markedReaderIndex;
        if (markReaderIndex <= decrement) {
            this._markedReaderIndex = 0;
            const markedWriterIndex:int = this._markedWriterIndex;
            if (markedWriterIndex <= decrement) {
                this._markedWriterIndex = 0;
            } else {
                this._markedWriterIndex = markedWriterIndex - decrement;
            }
        } else {
            this._markedReaderIndex = markedReaderIndex - decrement;
            _markedWriterIndex -= decrement;
        }
    }

    /**
     * @inheritDoc
     */
    public function ensureWritable(minWritableBytes:int):IByteBuf {
        if (minWritableBytes < 0) {
            throw new ArgumentError("minWritableBytes: " + minWritableBytes +
                    " (expected: >= 0)");
        }

        if (minWritableBytes <= writableBytes) {
            return this;
        }

        if (minWritableBytes >= _maxCapacity - _writerIndex) {
            throw new ArgumentError("writerIndex(" + _writerIndex + ")" +
                    " + minWritableBytes(" + minWritableBytes + ")" +
                    " exceeds maxCapacity(" + _maxCapacity + ")");
        }

        // Normailze the current capacity to the power of 2.
        const newCapacity = alloc().calculateNewCapacity(_writerIndex +
                minWritableBytes, _maxCapacity);

        // Adjust to the new capacity.
        this.capacity = newCapacity;
        return this;
    }

    /**
     * @inheritDoc
     */
    public function get endian():String {
        return _endian;
    }

    /**
     * @inheritDoc
     */
    public function set endian(value:String):void {
        if (_endian == value)
            return;
        // TODO:
    }

    //----------------------------------
    // I/O Operation members
    //----------------------------------

    /**
     * @inheritDoc
     */
    [Inline]
    public function getBoolean(index:int):Boolean {
        return getByte(index) != 0;
    }

    public function getByte(index:int):int {
        checkIndex(index);
        return _getByte(index);
    }

    protected function _getByte(index:int):int {
        throw "Not implementation.";
    }

    public function getUnsignedByte(index:int):int {
        return getByte(index) & 0xFF;
    }

    /**
     * @inheritDoc
     */
    public function getShort(index:int):int {
        checkIndex(index, 2);
        return _getShort(index);
    }

    /**
     * @inheritDoc
     */
    public function getUnsignedShort(index:int):int {
        return getShort(index) & 0xFFFF;
    }

    protected function _getShort(index:int):int {
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function getMedium(index:int):int {
        var value:int = getUnsignedMedium(index);
        if ((value & 0x800000) != 0) {
            value |= 0xFF000000;
        }
        return value;
    }

    /**
     * @inheritDoc
     */
    public function getUnsignedMedium(index:int):int {
        checkIndex(index, 3);
        return _getUnsignedMedium(index);
    }

    protected function _getUnsignedMedium(index:int):int {
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function getInt(index:int):int {
        checkIndex(index, 4);
        return _getInt(index);
    }

    /**
     * @inheritDoc
     */
    public function getUnsignedInt(index:int):uint {
        return getInt(index) & 0xFFFFFFFF;
    }

    public function _getInt(index:int):int {
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function getLong(index:int):Number {
        checkIndex(index, 8);
        return _getLong(index);
    }

    protected function _getLong(index:int):Number {
        throw "Not implementation.";
    }

    [Inline]
    /**
     * @inheritDoc
     */
    public function getChar(index:int):int {
        return getShort(index);
    }

    /**
     * @inheritDoc
     */
    public function getFloat(index:int):Number {
        return _getFloat(index);
    }

    protected function _getFloat(index:int):Number {
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function getDouble(index:int):Number {
        return _getDouble(index);
    }

    protected function _getDouble(index:int):Number {
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function getBytes(index:int, dst:IByteBuf, dstIndex:int = -1,
                             length:int = 0):IByteBuf {
        length = (length <= 0 ? dst.writableBytes : length);
        dstIndex = (dstIndex < 0 ? dst.writerIndex : dstIndex);
        _getBytes(index, dst, dstIndex, length);
        dst.writerIndex = dst.writerIndex + length;
        return this;
    }

    protected function _getBytes(index:int, dst:IByteBuf, dstIndex:int,
                                 length:int):void {
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function getByteArray(index:int, dst:ByteArray, dstIndex:int = -1,
                                 length:int = 0):IByteBuf {
        length = (length <= 0 ? dst.bytesAvailable : length);
        dstIndex = (dstIndex < 0 ? dst.position : dstIndex);
        const pos:uint = dst.position;
        _getByteArray(index, dst, dstIndex, length);
        dst.position = pos + length;
        return this;
    }

    protected function _getByteArray(index:int, dst:ByteArray, dstIndex:int,
                                     length:int):void {
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function setBoolean(index:int, value:Boolean):IByteBuf {
        setByte(index, value ? 1 : 0);
        return this;
    }

    /**
     * @inheritDoc
     */
    public function setByte(index:int, value:int):IByteBuf {
        checkIndex(index);
        _setByte(index, value);
        return this;
    }

    protected function _setByte(index:int, value:int):void {
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function setShort(index:int, value:int):IByteBuf {
        checkIndex(index, 2);
        _setShort(index, value);
        return this;
    }

    protected function _setShort(index:int, value:int):void {
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function setMedium(index:int, value:int):IByteBuf {
        checkIndex(index, 3);
        _setMedium(index, value);
        return this;
    }

    protected function _setMedium(index:int, value:int):void {
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function setInt(index:int, value:int):IByteBuf {
        checkIndex(index, 4);
        _setInt(index, value);
        return this;
    }

    protected function _setInt(index:int, value:int):void {
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function setLong(index:int, value:Number):IByteBuf {
        checkIndex(index, 8);
        _setLong(index, value);
        return this;
    }

    protected function _setLong(index:int, value:Number):void {
        throw "Not implementation.";
    }

    [Inline]
    /**
     * @inheritDoc
     */
    public function setChar(index:int, value:int):IByteBuf {
        return setShort(index, value);
    }

    /**
     * @inheritDoc
     */
    public function setFloat(index:int, value:Number):IByteBuf {
        checkIndex(index, 4);
        _setFloat(index, value);
        return this;
    }

    protected function _setFloat(index:int, value:Number):void {
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function setDouble(index:int, value:Number):IByteBuf {
        checkIndex(index, 8);
        _setDouble(index, value);
        return this;
    }

    protected function _setDouble(index:int, value:Number):void {
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function setBytes(index:int, src:IByteBuf, srcIndex:int = -1,
                             length:int = 0):IByteBuf {
        length = (length <= 0 ? src.readableBytes : length);
        srcIndex = (srcIndex < 0 ? src.readerIndex : srcIndex);
        checkIndex(index, length);
        if (length > src.readableBytes) {
            throw new ArgumentError("length(" + length + ") exceeds " +
                    "src.readableBytes(" + src.readableBytes + ")");
        }

        _setBytes(index, src, srcIndex, length);
        src.readerIndex = src.readerIndex + length;
        return this;
    }

    protected function _setBytes(index:int, src:IByteBuf, srcIndex:int,
                                 length:int):void {
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function setByteArray(index:int, src:ByteArray, srcIndex:int = -1, length:int = 0):IByteBuf {
        length = (length <= 0 ? src.bytesAvailable : length);
        srcIndex = (srcIndex < 0 ? src.position : srcIndex);
        checkIndex(index, length);
        if (length > src.bytesAvailable) {
            throw new ArgumentError("length(" + length + ") exceeds " +
                    "src.bytesAvailable(" + src.bytesAvailable + ")");
        }

        const pos:int = src.position;
        _setByteArray(index, src, srcIndex, length);
        src.position = pos + length;
        return this;
    }

    protected function _setByteArray(index:int, src:ByteArray, srcIndex:int, length:int):void {
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function setZero(index:int, length:int):IByteBuf {
        if (0 == length)
            return this;

        checkIndex(index, length);

        const nLong:int = length >>> 3;
        const nBytes:int = length & 7;
        var i:int;
        for (i = nLong; i > 0; i--) {
            setLong(index, 0);
            index += 8;
        }

        if (nBytes == 4) {
            setInt(index, 0);
        } else if (nBytes < 4) {
            for (i = nBytes; i > 0; i--) {
                setByte(index, 0);
                index++;
            }
        } else {
            setInt(index, 0);
            index += 4;
            for (i = nBytes - 4; i > 0; i--) {
                setByte(index, 0);
                index++;
            }
        }
        return this;
    }

    /**
     * @inheritDoc
     */
    public function readByte():int {
        checkIndex(_readerIndex);
        const ret:int = _getByte(_readerIndex);
        _readerIndex += 1;
        return ret;
    }

    /**
     * @inheritDoc
     */
    public function readUnsignedByte():uint {
        return readByte() & 0xFF;
    }

    /**
     * @inheritDoc
     */
    public function readBoolean():Boolean {
        return readByte() != 0;
    }

    /**
     * @inheritDoc
     */
    public function readShort():int {
        checkIndex(_readerIndex, 2);
        const ret:int = _getShort(_readerIndex);
        _readerIndex += 2;
        return ret;
    }

    /**
     * @inheritDoc
     */
    public function readUnsignedShort():uint {
        return readShort() & 0xFFFF;
    }

    /**
     * @inheritDoc
     */
    public function readChar():int {
        return readShort();
    }

    /**
     * @inheritDoc
     */
    public function readMedium():int {
        var value:int = readUnsignedMedium();
        if ((value & 0x800000) != 0) {
            value |= 0xFF000000;
        }
        return value;
    }

    /**
     * @inheritDoc
     */
    public function readUnsignedMedium():uint {
        checkIndex(_readerIndex, 3);
        const v:int = _getUnsignedMedium(_readerIndex);
        _readerIndex += 3;
        return v;
    }

    /**
     * @inheritDoc
     */
    public function readInt():int {
        checkIndex(_readerIndex, 4);
        const v:int = _getInt(_readerIndex);
        _readerIndex += 4;
        return v;
    }

    /**
     * @inheritDoc
     */
    public function readUnsignedInt():uint {
        return readInt() & 0xFFFFFFFF;
    }

    /**
     * @inheritDoc
     */
    public function readLong():Number {
        checkIndex(_readerIndex, 8);
        const v:Number = _getLong(_readerIndex);
        _readerIndex += 8;
        return v;
    }

    /**
     * @inheritDoc
     */
    public function readFloat():Number {
        checkIndex(_readerIndex, 4);
        const v:Number = _getFloat(_readerIndex);
        _readerIndex += 4;
        return v;
    }

    /**
     * @inheritDoc
     */
    public function readDouble():Number {
        checkIndex(_readerIndex, 8);
        const v:Number = _getLong(_readerIndex);
        _readerIndex += 8;
        return v;
    }

    /**
     * @inheritDoc
     */
    public function readBytes(dst:ByteArray, offset:uint = 0, length:uint =
            0):void {
        length = length <= 0 ? readableBytes : length;
        checkIndex(_readerIndex, length);

        offset = offset < 0 ? 0 : offset;
        _getByteArray(_readerIndex, dst, offset, length);
        _readerIndex += length;
    }

    /**
     * @inheritDoc
     */
    public function readSlice(length:int):IByteBuf {
        const s:IByteBuf = slice(_readerIndex, length);
        _readerIndex += length;
        return s;
    }

    /**
     * @inheritDoc
     */
    public function skipBytes(length:int):IByteBuf {
        checkIndex(_readerIndex, length);
        _readerIndex += length;
        return this;
    }

    /**
     * @inheritDoc
     */
    public function writeBoolean(value:Boolean):void {
        writeByte(value ? 1 : 0);
    }

    /**
     * @inheritDoc
     */
    public function writeByte(value:int):void {
        ensureWritable(1);
        _setByte(_writerIndex++, value);
    }

    /**
     * @inheritDoc
     */
    public function writeShort(value:int):void {
        ensureWritable(2);
        _setShort(_writerIndex, value);
        _writerIndex += 2;
    }

    /**
     * @inheritDoc
     */
    public function writeMedium(value:int):IByteBuf {
        ensureWritable(3);
        _setMedium(_writerIndex, value);
        _writerIndex += 3;
        return this;
    }

    /**
     * @inheritDoc
     */
    public function writeInt(value:int):void {
        ensureWritable(4);
        _setInt(_writerIndex, value);
        _writerIndex += 4;
    }

    /**
     * @inheritDoc
     */
    public function writeLong(value:Number):IByteBuf {
        ensureWritable(8);
        _setLong(_writerIndex, value);
        _writerIndex += 8;
        return this;
    }

    /**
     * @inheritDoc
     */
    public function writeFloat(value:Number):void {
        ensureWritable(4);
        _setFloat(_writerIndex, value);
        _writerIndex += 4;
    }

    /**
     * @inheritDoc
     */
    public function writeDouble(value:Number):void {
        ensureWritable(8);
        _setDouble(_writerIndex, value);
        _writerIndex += 8;
    }

    /**
     * @inheritDoc
     */
    public function writeChar(value:int):IByteBuf {
        writeShort(value);
        return this;
    }

    /**
     * @inheritDoc
     */
    public function writeBytes(dst:ByteArray, offset:uint = 0, length:uint =
            0):void {
        length = length <= 0 ? dst.bytesAvailable : length;
        ensureWritable(length);
        offset = offset < 0 ? 0 : offset;
        _setByteArray(_writerIndex, dst, offset, length);
        _writerIndex += length;
    }

    /**
     * @inheritDoc
     */
    public function writeZero(length:int):IByteBuf {
        if (0 == length)
            return this;

        ensureWritable(length);
        checkIndex(_writerIndex, length);

        const nLong:int = length >>> 3;
        const nBytes:int = length & 7;
        var i:int;

        for (i = nLong; i > 0; i--) {
            writeLong(0);
        }

        if (nBytes == 4) {
            writeInt(0);
        } else if (nBytes < 4) {
            for (i = nBytes; i > 0; i--) {
                writeByte(0);
            }
        } else {
            writeInt(0);
            for (i = nBytes - 4; i > 0; i--) {
                writeByte(0);
            }
        }

        return this;
    }

    /**
     * @inheritDoc
     */
    public function copy(fromIndex:int = -1, length:int = 0):IByteBuf {
        fromIndex = fromIndex < 0 ? _readerIndex : fromIndex;
        length = length <= 0 ? readableBytes : length;
        return _copy(fromIndex, length);
    }

    protected function _copy(index:int, length:int):IByteBuf {
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function duplicate():IByteBuf {
        // TODO: new DuplicatedByteBuf.
    }

    /**
     * @inheritDoc
     */
    public function slice(index:int = -1, length:int = 0):IByteBuf {
        index = index < 0 ? _readerIndex : index;
        length = length <= 0 ? readableBytes : length;
        // TODO: new SliceByteBuf(this)
        throw "Not implementation.";
    }

    /**
     * @inheritDoc
     */
    public function get hasArray():Boolean {
        return false;
    }

    /**
     * @inheritDoc
     */
    public function get array():ByteArray {
        return null;
    }

    /**
     * @inheritDoc
     */
    public function get arrayOffset():int {
        return 0;
    }

    /**
     * @inheritDoc
     */
    public function indexOf(fromIndex:int, toIndex:int, value:int):int {
        // TODO: indexOf ByteBuf.
    }

    /** @private */
    protected final function checkIndex(index:int, fieldLength:int = 1):void {
        if (index < 0 || index > capacity - fieldLength) {
            throw new ArgumentError("index: " + index + ", length: " +
                    fieldLength + " (expected: range(0, " + capacity + "))");
        }
    }

    public function unwrap():IByteBuf {
        return null;
    }

    [cppcall]
    public function readMultiByte(length:uint, charSet:String):String {
        return "";
    }

    [cppcall]
    public function readUTF():String {
        return "";
    }

    [cppcall]
    public function readUTFBytes(length:uint):String {
        return "";
    }

    [cppcall]
    public function get bytesAvailable():uint {
        return 0;
    }

    [cppcall]
    public function readObject():* {
        return null;
    }

    [cppcall]
    public function get objectEncoding():uint {
        return 0;
    }

    [cppcall]
    public function set objectEncoding(version:uint):void {
    }

    public function writeUnsignedInt(value:uint):void {
    }

    public function writeMultiByte(value:String, charSet:String):void {
    }

    public function writeUTF(value:String):void {
    }

    public function writeUTFBytes(value:String):void {
    }

    public function writeObject(object:*):void {
    }

    public function get objectEncoding():uint {
        return 0;
    }

    public function set objectEncoding(version:uint):void {
    }

} // class AbstractByteBuf
}
