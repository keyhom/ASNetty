package io.asnetty.channel {

/**
 * @author Jeremy
 */
public final class WriteBufferWaterMark {

    public static const DEFAULT_LOW_WATER_MARK:int = 32 * 1024;
    public static const DEFAULT_HIGH_WATER_MARK:int = 64 * 1024;

    /** @readonly */
    public static const DEFAULT:WriteBufferWaterMark = new WriteBufferWaterMark(DEFAULT_LOW_WATER_MARK, DEFAULT_HIGH_WATER_MARK, false);

    private var _low:int;
    private var _high:int;

    /**
     * Constructor
     */
    public function WriteBufferWaterMark(low:int, high:int, validate:Boolean = true) {
        super();
        if (validate) {
            if (0 > low) {
                throw new Error("Write buffer's low water mark must be >= 0.");
            }

            if (high < low) {
                throw new Error("Write buffer's high water mark must > low water mark.");
            }
        }

        this._low = low;
        this._high = high;
    }

    public function get low():int {
        return _low;
    }

    public function get high():int {
        return _high;
    }

    public function toString():String {
        var str:String = "WriteBufferWaterMark(low: ";
        str += low;
        str += ", high: ";
        str += high;
        str += ")";
        return str;
    }

}
}

//import io.asnetty.channel.WriteBufferWaterMark;
//
//{
//    WriteBufferWaterMark.DEFAULT = new
//            WriteBufferWaterMark(WriteBufferWaterMark.DEFAULT_LOW_WATER_MARK,
//            WriteBufferWaterMark.DEFAULT_HIGH_WATER_MARK, false);
//}
