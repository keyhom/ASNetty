package io.asnetty.util {
/**
 * Creates an <code>InternalLogger</code> or changes the default factory implementations.
 *
 * @author Jeremy
 */
public class InternalLoggerFactory {

    private static var _defaultFactory:InternalLoggerFactory;

    public static function get defaultFactory():InternalLoggerFactory {
        return _defaultFactory;
    }

    public static function set defaultFactory(value:InternalLoggerFactory):void {
        _defaultFactory = value;
    }

    public static function getInstance(nameOrClass:*):InternalLogger {
        const logName:String = nameOrClass.toString();
        return defaultFactory.newInstance(logName);
    }

    public function InternalLoggerFactory() {
        super();
    }

    protected virtual function newInstance(name:String):InternalLogger {
        // NOOP.
        return null;
    }

}
}

import flash.utils.Dictionary;

import io.asnetty.util.InternalLogger;
import io.asnetty.util.InternalLoggerFactory;
import io.asnetty.util.TraceLogger;

class TraceLoggerFactory extends InternalLoggerFactory {

    private var _caches:Dictionary;

    public function TraceLoggerFactory() {
        super();

        _caches = new Dictionary();
    }

    override protected function newInstance(name:String):InternalLogger {
        var ret:InternalLogger;
        if (name in _caches) {
            ret = _caches[name] as InternalLogger;
        }

        if (!ret) {
            ret = new TraceLogger(name);

            _caches[name] = ret;
        }

        return ret;
    }

}

// Set static default variables.
{
    InternalLoggerFactory.defaultFactory = new TraceLoggerFactory();
}
