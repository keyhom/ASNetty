package io.asnetty.buffer {

import flash.utils.ByteArray;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;

/**
 * A random and sequential accessible sequence of zero or more bytes (octets).
 *
 * @author Jeremy
 */
public interface IByteBuf extends IDataInput, IDataOutput {

    /**
     * Returns the number of bytes (octets) this buffer can contains.
     */
    function get capacity():int;

    /**
     * @private
     */
    function set capacity(value:int):void;

    /**
     * Returns the maximum allowed capacity of this buffer.
     */
    function get maxCapacity():int;

    /**
     * Returns the underlying buffer instance if this buffer is a wrapper of
     * another buffer.
     */
    function unwrap():IByteBuf;

    /**
     * Returns the <code>readerIndex</code> of this buffer.
     */
    function get readerIndex():int;

    /**
     * @private
     */
    function set readerIndex(value:int):void;

    /**
     * Returns the <code>writerIndex</code> of this buffer.
     */
    function get writerIndex():int;

    /**
     * @private
     */
    function set writerIndex(value:int):void;

    /**
     * Sets the <code>readerIndex</code> and <code>writerIndex</code> of this
     * buffer in one shot.
     */
    function setIndex(readerIndex:int, writerIndex:int):IByteBuf;

    /**
     * Returns the number of readable bytes which is equals to
     * <code>(this.readerIndex - this.writerIndex)</code>.
     */
    function get readableBytes():int;

    /**
     * Returns the number of writable bytes which is equals to
     * <code>(this.capacity - this.writerIndex)</code>.
     */
    function get writableBytes():int;

    /**
     * Returns the maximum possible number of writable bytes, which is equals to
     * <code>(this.maxCapacity - this.writerIndex)</code>.
     */
    function get maxWritableBytes():int;

    /**
     * Returns <code>true</code> if and only if <code>(this.writerIndex -
     * this.readerIndex)</code> is greater than <code>size</code>.
     */
    function isReadable(size:int = 0):Boolean;

    /**
     * Returns <code>true</code> if and only if <code>(this.capacity -
     * this.writerIndex)</code> is greater than <code>size</code>.
     */
    function isWritable(size:int = 0):Boolean;

    /**
     * Sets the <code>readerIndex</code> and <code>writerIndex</code> of this
     * buffer to <code>0</code>.
     */
    function clear():IByteBuf;

    /**
     * Marks the current <code>readerIndex</code> in this buffer. You can
     * reposition the current <code>readerIndex</code> to the marked
     * <code>readerIndex</code> by calling <code>#resetReaderIndex()</code>. The
     * initial value of the marked <code>readerIndex</code> is <code>0</code>.
     */
    function markReaderIndex():IByteBuf;

    /**
     * Repositions the current <code>readerIndex</code> to the marked
     * <code>readerIndex</code> in this buffer.
     */
    function resetReaderIndex():IByteBuf;

    /**
     * Marks the current <code>writerIndex</code> in this buffer. You can
     * reposition the current <code>writerIndex</code> to the marked
     * <code>writerIndex</code> by calling <code>#resetWriterIndex()</code>. The
     * initial value of the marked <code>writerIndex</code> is <code>0</code>.
     */
    function markWriterIndex():IByteBuf;

    /**
     * Repositions the current <code>writerIndex</code> to the marked
     * <code>writerIndex</code> in this buffer.
     */
    function resetWriterIndex():IByteBuf;

    /**
     * Discards the bytes between the 0th index and <code>readerIndex</code>. It
     * moves the bytes between <code>readerIndex</code> and
     * <code>writerIndex</code> to the 0th index, and sets
     * <code>readerIndex</code> and <code>writerIndex</code> to <code>0</code>
     * and <code>oldWriterIndex - oldReaderIndex</code> respectively.
     */
    function discardReadBytes():IByteBuf;

    /**
     * Similar to <code>discardReadBytes()</code> expect that this method might
     * discard some, all or none of read bytes depending on its internal
     * implementation to reduce overall memory bandwidth consumption at the cost
     * of potentially additional memory consumption.
     */
    function discardSomeReadBytes():IByteBuf;

    /**
     * Makes sure the number of <code>#writableBytes()</code> the writable bytes
     * is equal to or greater than the specified value. If there is enough
     * writable bytes in this buffer, this method returns with no side effect.
     * Otherwise, it raises an <code>ArgumentError</code>.
     */
    function ensureWritable(minWritableBytes:int):IByteBuf;

    /**
     * Gets a boolean at the specified absolute <code>index</code> in this
     * buffer.
     */
    function getBoolean(index:int):Boolean;

    /**
     * Gets a byte at the specified absolute <code>index</code> in this buffer.
     */
    function getByte(index:int):int;

    /**
     * Gets an unsigned-byte at the specified absolute <code>index</code> in this
     * buffer.
     */
    function getUnsignedByte(index:int):int;

    /**
     * Gets a short at the specified absolute <code>index</code> in
     * this buffer.
     */
    function getShort(index:int):int;

    /**
     * Gets an unsigned-short at the specified absolute <code>index</code> in
     * this buffer.
     */
    function getUnsignedShort(index:int):int;

    /**
     * Gets a 24-bit medium integer at the specified absolute <code>index</code>
     * in this buffer.
     */
    function getMedium(index:int):int;

    /**
     * Gets an unsigned 24-bit medium integer at the specified absolute
     * <code>index</code> in this buffer.
     */
    function getUnsignedMedium(index:int):int;

    /**
     * Gets a 32-bit medium integer at the specified absolute
     * <code>index</code> in this buffer.
     */
    function getInt(index:int):int;

    /**
     * Gets an unsigned 32-bit medium integer at the specified absolute
     * <code>index</code> in this buffer.
     */
    function getUnsignedInt(index:int):uint;

    /**
     * Gets an 64-bit long integer at the specified absolute <code>index</code>
     * in this buffer.
     */
    function getLong(index:int):Number;

    /**
     * Gets a 2-byte UTF-16 character at the specified absolute
     * <code>index</code> in this buffer.
     */
    function getChar(index:int):int;

    /**
     * Gets a 32-bit floating point number at the specified absolute
     * <code>index</code> in this buffer.
     */
    function getFloat(index:int):Number;

    /**
     * Gets a 64-bit floating point number at the specified absolute
     * <code>index</code> in this buffer.
     */
    function getDouble(index:int):Number;

    /**
     * Transfers this buffer's data to the specified destination starting at the
     * specified absolute <code>index</code>.
     */
    function getBytes(index:int, dst:IByteBuf, dstIndex:int = 0,
            length:int = 0):IByteBuf;

    /**
     * Transfers this buffer's data to the specified destination starting at the
     * specified absolute <code>index</code>.
     */
    function getByteArray(index:int, dst:ByteArray, dstIndex:int = 0,
            length:int = 0):IByteBuf;

    /**
     * Sets the specified boolean at the specified absolute <code>index</code>
     * in this buffer.
     */
    function setBoolean(index:int, value:Boolean):IByteBuf;

    /**
     * Sets the specified byte at the specified absolute <code>index</code> in
     * this buffer.
     */
    function setByte(index:int, value:int):IByteBuf;

    /**
     * Sets the specified short at the specified absolute <code>index</code> in
     * this buffer.
     */
    function setShort(index:int, value:int):IByteBuf;

    /**
     * Sets the specified 24-bit integer at the specified absolute
     * <code>index</code> in this buffer.
     */
    function setMedium(index:int, value:int):IByteBuf;

    /**
     * Sets the specified 32-bit integer at the specified absolute
     * <code>index</code> in this buffer.
     */
    function setInt(index:int, value:int):IByteBuf;

    /**
     * Sets the specified 64-bit integer at the specified absolute
     * <code>index</code> in this buffer.
     */
    function setLong(index:int, value:Number):IByteBuf;

    /**
     * Sets the specified 2-byte UTF-16 character at the specified absolute
     * <code>index</code> in this buffer.
     */
    function setChar(index:int, value:int):IByteBuf;

    /**
     * Sets the specified 32-bit floating number at the specified absolute
     * <code>index</code> in this buffer.
     */
    function setFloat(index:int, value:Number):IByteBuf;

    /**
     * Sets the specified 64-bit floating number at the specified absolute
     * <code>index</code> in this buffer.
     */
    function setDouble(index:int, value:Number):IByteBuf;

    /**
     * Transfers the specified source buffer's data into this buffer starting at
     * the specified absolute <code>index</code>.
     */
    function setBytes(index:int, src:IByteBuf, srcIndex:int = 0,
            length:int = 0):IByteBuf;

    /**
     * Transfers the specified source buffer's data into this buffer starting at
     * the specified absolute <code>index</code>.
     */
    function setByteArray(index:int, src:ByteArray, srcIndex:int = 0,
            length:int = 0):IByteBuf;

    /**
     * Fills the buffer with <tt>NUL (0x00)</tt> starting at the specified
     * absolute <code>index</code>.
     */
    function setZero(index:int, length:int):IByteBuf;

    /**
     * Gets a 24-bit medium integer at the current <code>readerIndex</code> and
     * increases the <code>readerIndex</code> by <code>3</code> in this buffer.
     */
    function readMedium():int;

    /**
     * Gets a 24-bit unsigned medium integer at the current
     * <code>readerIndex</code> and increases the <code>readerIndex</code> by
     * <code>3</code> in this buffer.
     */
    function readUnsignedMedium():uint;

    /**
     * Increases the current <code>readerIndex</code> by the specified
     * <code>length</code> in this buffer.
     */
    function skipBytes(length:int):IByteBuf;

    /**
     * Sets the specified 24-bit medium integer at the current
     * <code>writerIndex</code> and increases the <code>writerIndex</code> by
     * <code>3</code> in this buffer.
     */
    function writeMedium(value:int):IByteBuf;

    /**
     * Sets the specified 64-bit medium integer at the current
     * <code>writerIndex</code> and increases the <code>writerIndex</code> by
     * <code>8</code> in this buffer.
     */
    function writeLong(value:Number):IByteBuf;

    /**
     * Sets the specified 2-byte UTF-16 character at the current
     * <code>writerIndex</code> and increases the <code>writerIndex</code> by
     * <code>2</code> in this buffer.
     */
    function writeChar(value:int):IByteBuf;

    /**
     * Fills the buffer with <tt>NUL (0x00)</tt> starting at the current
     * <code>writerIndex</code> and increases the <code>writerIndex</code> by
     * the specified <code>length</code>.
     */
    function writeZero(length:int):IByteBuf;

    /**
     * Locates the first occurrence of the specified <code>value</code> in this
     * buffer. The search takes place from the specified <code>fromIndex</code>
     * (inclusive) to the specified <code>toIndex</code> (exclusive).
     */
    function indexOf(fromIndex:int, toIndex:int, value:int):int;

    /**
     * Returns a copy of this buffer's readable bytes. Modifying the content of
     * the returned buffer or this buffer does not affect each other at all.
     */
    function copy(index:int = 0, length:int = 0):IByteBuf;

    /**
     * Returns a slice of this buffer's sub-region. Modifying the content of the
     * returned buffer or this buffer affects each other's content while they
     * maintain separate indexes and marks.
     */
    function slice(index:int = 0, length:int = 0):IByteBuf;

    /**
     * Returns a buffer which shares the whole region of this buffer. Modifying
     * the content of the returned buffer or this buffer affects each other's
     * content while they maintain separate indexes and marks.
     */
    function duplicate():IByteBuf;

    /**
     * Returns <code>true</code> if and only if this buffer has a backing byte
     * array. If this method returns true, you can safely call
     * <code>#array</code> and <code>#arrayOffset</code>.
     */
    function get hasArray():Boolean;

    /**
     * Returns the backing byte array of this buffer.
     */
    function get array():ByteArray;

    /**
     * Returns the offset of the first byte within the backing byte array of
     * this buffer.
     */
    function get arrayOffset():int;


} // class IByteBuf
}
