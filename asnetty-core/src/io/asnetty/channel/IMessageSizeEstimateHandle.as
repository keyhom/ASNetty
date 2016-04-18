package io.asnetty.channel {

/**
 * @author Jeremy
 */
public interface IMessageSizeEstimateHandle {

    /**
     * Calculates the size of the given message.
     *
     * @param msg The message for which the size should be calculated
     * @return size The size in bytes. The returned size must be >= 0
     */
    function size(msg:*):int;

}
}
