package io.asnetty.util {

/**
 * <em>Internal-use-only</em> Logger used by ASNetty. <strong>DO NOT</strong>
 * access this class outside of ASNetty.
 *
 * @author Jeremy
 */
public interface InternalLogger {

    /**
     * Return the name of this <code>InternalLogger</code> instance.
     */
    function get name():String;

    /**
     * Is the logger instance enabled for the TRACE level ?
     */
    function get isTraceEnabled():Boolean;

    /**
     * Log a message at the TRACE level.
     */
    function trace(... args):void;

    /**
     * Is the logger instance enabled for the DEBUG level ?
     */
    function get isDebugEnabled():Boolean;

    /**
     * Log a message at the DEBUG level.
     */
    function debug(... args):void;

    /**
     * Is the logger instance enabled for the INFO level ?
     */
    function get isInfoEnabled():Boolean;

    /**
     * Log a message at the INFO level.
     */
    function info(... args):void;

    /**
     * Is the logger instance enabled for the WARN level ?
     */
    function get isWarnEnabled():Boolean;

    /**
     * Log a message at the WARN level.
     */
    function warn(... args):void;

    /**
     * Is the logger instance enabled for the ERROR level ?
     */
    function get isErrorEnabled():Boolean;

    /**
     * Log a message at the ERROR level.
     */
    function error(... args):void;

    /**
     * Is the logger instance enabled for the specified <code>level</code>.
     */
    function isEnabled(level:int):Boolean;

    /**
     * Log a message at the specified <code>level</code> according to the
     * specified format and arguments.
     */
    function log(level:int, ... args):void;

} // interface InternalLogger
}
