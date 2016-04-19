package io.asnetty.util {

import avmplus.getQualifiedClassName;

/**
 * @author Jeremy
 */
public class TraceLogger extends AbstractInternalLogger {

    /** Creates a TraceLogger instance */
    public function TraceLogger(ref:*) {
        super(ref is String ? ref : getQualifiedClassName(ref));
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

    override protected function doTrace(format:String, ... args):void {
        const tuple:FormattingTuple = MessageFormatter.applyFormat(format, args);
        trace(tuple.message);
        if (tuple.throwable) throw tuple.throwable;
    }

    override protected function doDebug(format:String, ... args):void {
        const tuple:FormattingTuple = MessageFormatter.applyFormat(format, args);
        trace(tuple.message);
        if (tuple.throwable) throw tuple.throwable;
    }

    override protected function doInfo(format:String, ... args):void {
        const tuple:FormattingTuple = MessageFormatter.applyFormat(format, args);
        trace(tuple.message);
        if (tuple.throwable) throw tuple.throwable;
    }

    override protected function doWarn(format:String, ... args):void {
        const tuple:FormattingTuple = MessageFormatter.applyFormat(format, args);
        trace(tuple.message);
        if (tuple.throwable) throw tuple.throwable;
    }

    override protected function doError(format:String, ... args):void {
        const tuple:FormattingTuple = MessageFormatter.applyFormat(format, args);
        trace(tuple.message);
        if (tuple.throwable) throw tuple.throwable;
    }

} // class TraceLogger
}
