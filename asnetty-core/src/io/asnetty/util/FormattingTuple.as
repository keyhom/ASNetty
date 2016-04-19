package io.asnetty.util {

/**
 * Holds the results of formatting done by <code>MessageFormatter</code>.
 *
 * @author Jeremy
 */
public class FormattingTuple {

    public static const NULL:FormattingTuple = new FormattingTuple(null);

    private var _message:String;
    private var _argArray:Array;
    private var _throwable:Error;

    /**
     * Creates a FormattingTuple instance.
     */
    public function FormattingTuple(message:String, argArray:Array = null,
            throwable:Error = null) {
        super();

        this._message = message;
        this._argArray = argArray;
        this._throwable = throwable;
    }

    public function get message():String { return _message; }

    public function get argArray():Array { return _argArray; }

    public function get throwable():Error { return _throwable; }

} // class FormattingTuple
}
