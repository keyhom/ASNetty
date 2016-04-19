package io.asnetty.channel {

/**
 * A default <code>IMessageSizeEstimator</code> implementation which supports
 * the estimation of the size of <code>ByteArray</code>.
 *
 * @author Jeremy
 */
public final class DefaultMessageSizeEstimator implements IMessageSizeEstimator {

    public static var DEFAULT:IMessageSizeEstimator;

    /** @private */
    private var _handle:IMessageSizeEstimateHandle;

    /** Constructor */
    public function DefaultMessageSizeEstimator(unknownSize:int) {
        super();
        if (unknownSize < 0)
            throw new Error("unknownSize: " + unknownSize + " (expected: >= 0)");

        _handle = new HandleImpl(unknownSize);
    }

    public function newHandle():IMessageSizeEstimateHandle {
        return _handle;
    }

} // class DefaultMessageSizeEstimator
}

import flash.utils.ByteArray;

import io.asnetty.channel.DefaultMessageSizeEstimator;
import io.asnetty.channel.IMessageSizeEstimateHandle;

/**
 * @author Jeremy
 */
final class HandleImpl implements IMessageSizeEstimateHandle {

    /** @private */
    private var _unknownSize:int;

    /** Constructor */
    public function HandleImpl(unknownSize:int) {
        super();
        this._unknownSize = unknownSize;
    }

    public function size(msg:*):int {
        if (msg is ByteArray) {
            return (msg as ByteArray).bytesAvailable;
        } else if (msg is String) {
            return msg.length;
        }
        return _unknownSize;
    }

}

{
    DefaultMessageSizeEstimator.DEFAULT = new DefaultMessageSizeEstimator(8);
}

