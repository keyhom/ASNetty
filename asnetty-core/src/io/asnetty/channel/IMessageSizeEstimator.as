package io.asnetty.channel {

/**
 * Responsible to estimate size of a message.
 * The size represent how much memory the message will ca. Reserve in memory.
 *
 * @author Jeremy
 */
public interface IMessageSizeEstimator {

    /**
     * Creates a new handle. The handle provides the actual operations.
     */
    function newHandle():IMessageSizeEstimateHandle;

}
}
