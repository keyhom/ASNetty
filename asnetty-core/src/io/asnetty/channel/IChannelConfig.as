package io.asnetty.channel {
import flash.utils.Dictionary;

/**
 * A set of configuration properties of a <code>IChannel</code>.
 *
 * @author Jeremy
 */
public interface IChannelConfig {

    /** Returns all set channel option's. */
    function getOptions(... args):Object;

    /** Sets the configuration properties from the specified
     * <code>options</code>. */
    function setOptions(options:Object):Boolean;

    /**
     * Returns the value of the given <code>key</code>.
     */
    function getOption(key:*):*;

    /**
     * Sets a configuration property with the specified named and value.
     */
    function setOption(key:*, value:*):Boolean;

    function get connectTimeoutMillis():Number;

    function set connectTimeoutMillis(value:Number):void;

    function get writeSpinCount():int;

    function set writeSpinCount(value:int):void;

    function get autoRead():Boolean;

    function set autoRead(value:Boolean):void;

    function get writeBufferHighWaterMark():int;

    function get writeBufferLowWaterMark():int;

    function get messageSizeEstimator():IMessageSizeEstimator;

    function set messageSizeEstimator(value:IMessageSizeEstimator):void;

    function get writeBufferWaterMark():WriteBufferWaterMark;

}
}
