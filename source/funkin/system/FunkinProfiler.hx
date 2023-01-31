package funkin.system;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.FlxPool;
class FunkinProfiler {
    private static var __pool:FlxPool<FunkinProfilerEvent> = new FlxPool(FunkinProfilerEvent);
    private static inline function __getEvent(name:String)
        return __pool.get().set(name);

    public static var events:Array<FunkinProfilerEvent> = [];

    public static function reset() {
        for(e in events)
            e.recycle();
    }

    public static function registerEvent(event:String, level:Int = 0) {
        var curEventsArray = events;
        var l:Int = 0;
        var ev:FunkinProfilerEvent;
        while(l < level) {
            ev = curEventsArray.last();
            if (ev == null)
                curEventsArray.push(ev = __getEvent("Unknown"));
            curEventsArray = ev.childs;
            l++;
        }

        curEventsArray.push(__getEvent(event));
    }

}

class FunkinProfilerEvent implements IFlxDestroyable {
    public var name:String = null;
    public var childs:Array<FunkinProfilerEvent> = [];

    public function new() {}

    public function set(name:String):FunkinProfilerEvent {
        this.name = name;
        if (childs != null)
            while(childs.length > 0)
                childs.shift();
        else
            childs = [];
        return this;
    }

    public function destroy() {
        name = null;
        childs = null;
    }

    public function recycle() {
        name = null;
        if (childs != null)
            for(c in childs)
                if (c != null)
                    c.recycle();
        @:privateAccess
        FunkinProfiler.__pool.put(this);
    }
}