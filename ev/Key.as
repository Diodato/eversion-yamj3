//****************************************************************************
// ActionScript Standard Library
// Key object
//****************************************************************************

intrinsic class Key
{
	static var _listeners:Array;
	static var ALT         :Number =   18;
	static var BACKSPACE   :Number =   8;
	static var CAPSLOCK    :Number =   20;
	static var CONTROL     :Number =   17;
	static var INSERT      :Number =   45;
	static var DELETEKEY   :Number =   46;
	static var DOWN        :Number =   40;
	static var END         :Number =   35;
	static var ENTER       :Number =   13;
	static var ESCAPE      :Number =   27;
	static var HOME        :Number =   36;
	static var LEFT        :Number =   37;
	static var PGDN        :Number =   34;
	static var PGUP        :Number =   33;
	static var RIGHT       :Number =   39;
	static var SHIFT       :Number =   16;
	static var SPACE       :Number =   32;
	static var TAB         :Number =   9;
	static var UP          :Number =   38;

	static function addListener(listener:Object):Void;
	static function getAscii():Number;
	static function getCode():Number;
	static function isDown(code:Number):Boolean;
	static function isToggled(code:Number):Boolean;
	static function removeListener(listener:Object):Boolean;
	static function isAccessible():Boolean;
	
	// Mobile specific
	//static function getCode():String;

    // Digital Home inspired Key defs
    //
    static var POWER                :Number =   0x01000000; // basic power toggle
    static var VOLUME_UP            :Number =   0x01000001; // volume up
    static var VOLUME_DOWN          :Number =   0x01000002; // volume down
    static var VOLUME_MUTE          :Number =   0x01000003; // volume mute
    static var CHANNEL_UP           :Number =   0x01000004; // channel up
    static var CHANNEL_DOWN         :Number =   0x01000005; // channel down
    static var RECORD               :Number =   0x01000006; // record item or engage record transport mode
    static var PLAY                 :Number =   0x01000007; // engage play transport mode
    static var PAUSE                :Number =   0x01000008; // engage pause transport mode
    static var STOP                 :Number =   0x01000009; // engage stop transport mode
    static var FAST_FORWARD         :Number =   0x0100000A; // engage fast-forward transport mode
    static var REWIND               :Number =   0x0100000B; // engage rewind transport mode
    static var SKIP_FORWARD         :Number =   0x0100000C; // quick skip ahead (usually 30 seconds)
    static var SKIP_BACKWARD        :Number =   0x0100000D; // quick skip backward (usually 7-10 seconds)
    static var NEXT                 :Number =   0x0100000E; // skip to next track or chapter
    static var PREVIOUS             :Number =   0x0100000F; // skip to previous track or chapter
    static var LIVE                 :Number =   0x01000010; // return to live [position in broadcast]
    static var LAST                 :Number =   0x01000011; // watch last channel or show watched
    static var MENU                 :Number =   0x01000012; // engage menu
    static var INFO                 :Number =   0x01000013; // info button
    static var GUIDE                :Number =   0x01000014; // engage program guide
    static var EXIT                 :Number =   0x01000015; // exits current application mode
    static var BACK                 :Number =   0x01000016; // return back to previous page in application
    static var AUDIO                :Number =   0x01000017; // select the audio mode
    static var SUBTITLE             :Number =   0x01000018; // toggle subtitles
    static var DVR                  :Number =   0x01000019; // engage dvr application mode
    static var VOD                  :Number =   0x0100001A; // engage video on demand
    static var INPUT                :Number =   0x0100001B; // cycle input
    static var SETUP                :Number =   0x0100001C; // engage setup application or menu
    static var HELP                 :Number =   0x0100001D; // engage help application or context-sensitive help
    static var MASTER_SHELL         :Number =   0x0100001E; // engage "Master Shell" e.g. TiVo or other vendor button
    static var RED                  :Number =   0x0100001F; // red function key button
    static var GREEN                :Number =   0x01000020; // green function key button
    static var YELLOW               :Number =   0x01000021; // yellow function key button
    static var BLUE                 :Number =   0x01000022; // blue function key button
    
    //#ifdef SYABAS_PORT
    
    //KEY RANGE assigned by Adobe
    //===========================

    //Assignee    Key Range Start    Key Range Stop
    //========    ===============    ==============
    //Syabas      0x10000400         0x100004FF
    static var SYABAS_FUNCTION_1    :Number =   0x10000400;
    static var SYABAS_FUNCTION_2    :Number =   0x10000401;
    static var SYABAS_FUNCTION_3    :Number =   0x10000402;
    static var SYABAS_FUNCTION_4    :Number =   0x10000403;
    static var SYABAS_SUSPEND       :Number =   0x10000404;
    static var SYABAS_FILEMODE      :Number =   0x10000405;
    static var SYABAS_TITLE         :Number =   0x10000406;
    static var SYABAS_REPEAT        :Number =   0x10000407;
    static var SYABAS_ANGLE         :Number =   0x10000408;
    static var SYABAS_SLOW          :Number =   0x10000409;
    static var SYABAS_TIMESEEK      :Number =   0x1000040A;
    static var SYABAS_ZOOM          :Number =   0x1000040B;
    static var SYABAS_TVMODE        :Number =   0x1000040C;
    static var SYABAS_AUDIO         :Number =   0x1000040D;
    static var SYABAS_SOURCE        :Number =   0x1000040E;
    static var SYABAS_EJECT         :Number =   0x1000040F;
    static var SYABAS_PLAY_PAUSE    :Number =   0x10000410;
    //#endif //#ifdef SYABAS_PORT
}
