package io.asnetty.handler.logging {
import io.asnetty.channel.ChannelDuplexHandler;
import io.asnetty.channel.IChannelHandlerContext;
import io.asnetty.channel.IChannelPromise;
import io.asnetty.util.InternalLogger;
import io.asnetty.util.InternalLoggerFactory;

/**
 * A <code>IChannelHandler</code> that logs all events using a logging
 * framework. By default, all events are logged at <tt>DEBUG</tt> level.
 *
 * @author Jeremy
 */
public class LoggingHandler extends ChannelDuplexHandler {

    private static const DEFAULT_LEVEL:int = LogLevel.DEBUG;

    protected var logger:InternalLogger;
    protected var internalLevel:int;

    private var _level:int;

    public function LoggingHandler(name:String = null, level:int = LogLevel.DEBUG) {
        logger = InternalLoggerFactory.getInstance(name ? name : LoggingHandler);
        this._level = level;
    }

    public function get level():int {
        return _level;
    }

    protected static function format(ctx:IChannelHandlerContext, eventName:String, ...args):String {
        var str:String = ctx.channel['toString']();
        str += ' ';
        str += eventName;
        var i:int = 0;
        if (args.length > 0) {
            for each (var va:* in args) {
                if (va) {
                    if (i > 0)
                        str += ',';
                    else if (i == 0) {
                        str += ': ';
                    }
                    str += va.toString();
                }
                i++;
            }
        }

        return str;
    }

    override public function channelActive(ctx:IChannelHandlerContext):void {
        if (logger.isEnabled(internalLevel)) {
            logger.log(internalLevel, format(ctx, "ACTIVE"));
        }
        ctx.fireChannelActive();
    }

    override public function channelInactive(ctx:IChannelHandlerContext):void {
        if (logger.isEnabled(internalLevel)) {
            logger.log(internalLevel, format(ctx, "INACTIVE"));
        }
        ctx.fireChannelInactive();
    }

    override public function channelRead(ctx:IChannelHandlerContext, msg:*):void {
        if (logger.isEnabled(internalLevel)) {
            logger.log(internalLevel, format(ctx, "RECEIVED", msg));
        }
        ctx.fireChannelRead(msg);
    }

    override public function errorCaught(ctx:IChannelHandlerContext, cause:Error):void {
        if (logger.isEnabled(internalLevel)) {
            logger.log(internalLevel, format(ctx, "ERROR", cause.toString()));
        }
        ctx.fireErrorCaught(cause);
    }

    override public function connect(ctx:IChannelHandlerContext, host:String, port:int, promise:IChannelPromise = null):void {
        if (logger.isEnabled(internalLevel)) {
            logger.log(internalLevel, format(ctx, "CONNECT", host, port));
        }
        ctx.makeConnect(host, port, promise);
    }

    override public function disconnect(ctx:IChannelHandlerContext, promise:IChannelPromise = null):void {
        if (logger.isEnabled(internalLevel)) {
            logger.log(internalLevel, format(ctx, "DISCONNECT"));
        }
        ctx.makeDisconnect(promise);
    }

    override public function close(ctx:IChannelHandlerContext, promise:IChannelPromise = null):void {
        if (logger.isEnabled(internalLevel)) {
            logger.log(internalLevel, format(ctx, "CLOSE"));
        }
        ctx.makeClose(promise);
    }

    override public function write(ctx:IChannelHandlerContext, msg:*, promise:IChannelPromise = null):void {
        if (logger.isEnabled(internalLevel)) {
            logger.log(internalLevel, format(ctx, "WRITE", msg));
        }
        ctx.makeWrite(msg, promise);
    }

    override public function flush(ctx:IChannelHandlerContext):void {
        if (logger.isEnabled(internalLevel)) {
            logger.log(internalLevel, format(ctx, "FLUSH"));
        }
        ctx.makeFlush();
    }

} // class LoggingHandler
}
