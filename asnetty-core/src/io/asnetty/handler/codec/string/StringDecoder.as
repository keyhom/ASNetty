package io.asnetty.handler.codec.string {

import flash.utils.ByteArray;

import io.asnetty.channel.IChannelHandlerContext;
import io.asnetty.handler.codec.MessageToMessageDecoder;

/**
 * Decodes a received <code>ByteArray</code> into a <code>String</code>.
 *
 * @author Jeremy
 */
public class StringDecoder extends MessageToMessageDecoder {

    /** @private */
    private var _charset:String;

    /**
     * Creates a StringDecoder instance.
     */
    public function StringDecoder(charset:String = "utf-8") {
        super(ByteArray);
        this._charset = charset;
    }

    /**
     * Returns the decode as charset.
     */
    public function get charset():String {
        return _charset;
    }

    /**
     * @inheritDoc
     */
    override protected function decode(ctx:IChannelHandlerContext,
                                       msg:*, out:Vector.<Object>):void {
        var bufIn:ByteArray = msg as ByteArray;
        if (!bufIn)
            return;
        out.push(bufIn.readMultiByte(bufIn.bytesAvailable, this._charset));
    }

} // class StringDecoder
}
