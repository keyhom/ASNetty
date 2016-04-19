package io.asnetty.util {

/**
 * A skeletal implemetation of <code>InternalLogger</code>. This class
 * implements all methods that have a <code>InternalLogLevel</code> parameter by
 * default to call specific logger methods such as <code>#info(String)</code> or
 * <code>#isInfoEnabled</code>.
 *
 * @author Jeremy
 */
public class AbstractInternalLogger implements InternalLogger {

    /** @private */
    private static const ERROR_MESSAGE:String = "Unexpected error:";

    /** @private */
    private var _name:String;

    /**
     * Creates a new instance.
     */
    public function AbstractInternalLogger(name:String) {
        super();
        if (!name) {
            throw new Error("NullPoint: name.");
        }
        this._name = name;
    }

    public function get name():String {
        return _name;
    }

    public function isEnabled(level:int):Boolean {
        switch (level) {
            case InternalLogLevel.TRACE:
                return isTraceEnabled;
            case InternalLogLevel.DEBUG:
                return isDebugEnabled;
            case InternalLogLevel.INFO:
                return isInfoEnabled;
            case InternalLogLevel.WARN:
                return isWarnEnabled;
            case InternalLogLevel.ERROR:
                return isErrorEnabled;
            default:
                throw new Error("Unexpected InternalLogLevel: " + level);
        }
    }

    public function log(level:int, ...args):void {
        switch (level) {
            case InternalLogLevel.TRACE:
                trace.apply(this, args);
                break;
            case InternalLogLevel.DEBUG:
                debug.apply(this, args);
                break;
            case InternalLogLevel.INFO:
                info.apply(this, args);
                break;
            case InternalLogLevel.WARN:
                warn.apply(this, args);
                break;
            case InternalLogLevel.ERROR:
                error.apply(this, args);
                break;
            default:
                throw new Error("Unexpected InternalLogLevel: " + level);
        }
    }

    public function get isTraceEnabled():Boolean {
        return false;
    }

    public final function trace(...args):void {
        if (!isTraceEnabled)
            return;

        var applyArgs:Array = args.slice();

        if (args.length == 1 && args[0] is Error) {
            applyArgs.unshift(ERROR_MESSAGE);
        }

        doTrace.apply(this, applyArgs);
    }

    protected function doTrace(format:String, ...args):void {
        // NOOP.
    }

    public function get isDebugEnabled():Boolean {
        return false;
    }

    public final function debug(...args):void {
        if (!isDebugEnabled)
            return;

        var applyArgs:Array = args.slice();

        if (args.length == 1 && args[0] is Error) {
            applyArgs.unshift(ERROR_MESSAGE);
        }

        doDebug.apply(this, applyArgs);
    }

    protected function doDebug(format:String, ...args):void {
        // NOOP
    }

    public function get isInfoEnabled():Boolean {
        return false;
    }

    public final function info(...args):void {
        if (!isInfoEnabled)
            return;

        var applyArgs:Array = args.slice();

        if (args.length == 1 && args[0] is Error) {
            applyArgs.unshift(ERROR_MESSAGE);
        }

        doInfo.apply(this, applyArgs);
    }

    protected function doInfo(format:String, ...args):void {
        // NOOP
    }

    public function get isWarnEnabled():Boolean {
        return false;
    }

    public final function warn(...args):void {
        if (!isWarnEnabled)
            return;

        var applyArgs:Array = args.slice();

        if (args.length == 1 && args[0] is Error) {
            applyArgs.unshift(ERROR_MESSAGE);
        }

        doWarn.apply(this, applyArgs);
    }

    protected function doWarn(format:String, ...args):void {
        // NOOP
    }

    public function get isErrorEnabled():Boolean {
        return false;
    }

    public final function error(...args):void {
        if (!isErrorEnabled)
            return;

        var applyArgs:Array = args.slice();

        if (args.length == 1 && args[0] is Error) {
            applyArgs.unshift(ERROR_MESSAGE);
        }

        doError.apply(this, applyArgs);
    }

    protected function doError(format:String, ...args):void {
        // NOOP
    }

} // class AbstractInternalLogger
}
