package io.asnetty.handler.codec.string {

import flash.utils.ByteArray;

import io.asnetty.channel.IChannelHandlerContext;
import io.asnetty.handler.codec.MessageToMessageEncoder;

/**
 * Encodes the requested <code>String</code> into a <code>ByteBuf</code>.
 *
 * @author Jeremy
 */
public class StringEncoder extends MessageToMessageEncoder {

    /** @private */
    private var _charset:String;

    /**
     * Creates a StringEncoder instance.
     */
    public function StringEncoder(charset:String = "utf-8") {
        super(String);
        this._charset = charset;
    }

    /**
     * Returns the encoded as charset.
     */
    public function get charset():String {
        return _charset;
    }

    /**
     * @inheritDoc
     */
    override protected function encode(ctx:IChannelHandlerContext, msg:*,
            out:Vector.<Object>):void {
        const str:String = String(msg);

        if (str.length == 0) {
            return;
        }

        var bs:ByteArray = new ByteArray();
        bs.writeMultiByte(str, this._charset);
        bs.position = 0;

        out.push(bs);
    }

} // class StringEncoder
}
