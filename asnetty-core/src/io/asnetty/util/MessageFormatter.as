package io.asnetty.util {

/**
 * Formats messages according to very simple substitution rules. Substitutions
 * can be made 1, 2 or more arguments.
 *
 * @author Jeremy
 */
public final class MessageFormatter {

    public static const DELIM_START:String = '{';
    public static const DELIM_STOP:String = '}';
    public static const DELIM_STR:String = '{}';

    private static const ESCAPE_CHAR:String = '\\';

    public static function applyFormat(format:String,
                                       args:Array):FormattingTuple {
        const throwableCandidate:Error = getThrowableCandidate(args);

        if (null == args || args.length == 0)
            return new FormattingTuple(format);

        var i:int = 0;
        var j:int;

        var sBuf:String = format.toString();
        var L:int;

        for (L = 0; L < args.length; L++) {
            j = format.indexOf(DELIM_STR, i);

            if (j == -1) {
                // no more variables.
                if (i == 0) { // this is a simple string
                    return new FormattingTuple(format, args,
                            throwableCandidate);
                } else { // add the tail string which contains no variables and
                    // return the result.
                    sBuf += format.substr(i, format.length);
                    return new FormattingTuple(sBuf, args, throwableCandidate);
                }
            } else {
                if (isEscapedDelimeter(format, j)) {
                    if (!isDoubleEscaped(format, j)) {
                        L--; // DELIM_START was escaped, thus should not be incremented.
                        sBuf += format.substr(i, j - 1);
                        sBuf += DELIM_START;
                        i = j + 1;
                    } else {
                        // The escape character preceding the delimiter start is
                        // itself escaped: "abc x:\\{}"
                        // we have to comsume one backward slash
                        sBuf += format.substr(i, j - 1);
                        sBuf += deeplyConcatParameter(args[L]);
                        i = j + 2;
                    }
                } else {
                    // normal case
                    sBuf += format.substr(i, j);
                    sBuf += deeplyConcatParameter(args[L]);
                    i = j + 2;
                }
            }
        }
        // append the characters following the last {} pair.
        sBuf += format.substr(i, format.length);
        if (L < args.length - 1) {
            return new FormattingTuple(sBuf, args, throwableCandidate);
        } else {
            return new FormattingTuple(sBuf, args, null);
        }
    }

    private static function deeplyConcatParameter(arg:*):String {
        if (null == arg)
            return "[null]";
        return arg.toString();
    }

    public static function isEscapedDelimeter(format:String, delimeterStartIndex:int):Boolean {
        if (delimeterStartIndex == 0)
            return false;
        return format.charAt(delimeterStartIndex - 1) == ESCAPE_CHAR;
    }

    public static function isDoubleEscaped(format:String, delimeterStartIndex:int):Boolean {
        return delimeterStartIndex >= 2 && format.charAt(delimeterStartIndex - 2) == ESCAPE_CHAR;
    }

    public static function getThrowableCandidate(args:Array):Error {
        if (null == args || args.length == 0)
            return null;

        const lastEntry:* = args[args.length - 1];
        if (lastEntry is Error)
            return lastEntry as Error;
        return null;
    }

} // class MessageFormatter
}
