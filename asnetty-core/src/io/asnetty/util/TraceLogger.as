package io.asnetty.util {

import avmplus.getQualifiedClassName;

import flash.globalization.DateTimeFormatter;

/**
 * @author Jeremy
 */
public class TraceLogger extends AbstractInternalLogger {

    private var _timeFormatter:DateTimeFormatter;

    /** Creates a TraceLogger instance */
    public function TraceLogger(ref:*) {
        super(ref is String ? ref : getQualifiedClassName(ref));
        _timeFormatter = new DateTimeFormatter("fmtTime");
        _timeFormatter.setDateTimePattern("HH:mm:ss SSS");
    }

    override public function get isTraceEnabled():Boolean {
        return true;
    }

    override public function get isDebugEnabled():Boolean {
        return true;
    }

    override public function get isInfoEnabled():Boolean {
        return true;
    }

    override public function get isWarnEnabled():Boolean {
        return true;
    }

    override public function get isErrorEnabled():Boolean {
        return true;
    }

    protected function doPrint(format:String, args:Array):void {
        const tuple:FormattingTuple = MessageFormatter.applyFormat(format, args);
        var str:String = _timeFormatter.format(new Date());
        AS3Trace.consoleTrace(str + " " + tuple.message);
        if (tuple.throwable) throw tuple.throwable;
    }

    override protected function doTrace(format:String, ...args):void {
        doPrint(format, args);
    }

    override protected function doDebug(format:String, ...args):void {
        doPrint(format, args);
    }

    override protected function doInfo(format:String, ...args):void {
        doPrint(format, args);
    }

    override protected function doWarn(format:String, ...args):void {
        doPrint(format, args);
    }

    override protected function doError(format:String, ...args):void {
        doPrint(format, args);
    }

} // class TraceLogger
}

final class AS3Trace {

    public static function consoleTrace(...rest):void {
        trace.apply(null, rest);
    }

    public function AS3Trace() {

    }
}
