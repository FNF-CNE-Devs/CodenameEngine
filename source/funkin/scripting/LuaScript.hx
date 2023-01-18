package funkin.scripting;

#if ENABLE_LUA
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;

import openfl.utils.Assets;

using llua.Lua;
using llua.LuaL;
using llua.Convert;

class LuaScript extends Script {
    public var state:State = null;

    public var lastStackID:Int = 0;
    public var stack:Map<Int, Dynamic> = [];

    public var luaCallbacks:Map<String, Dynamic> = [];

    public override function onCreate(path:String) {
        super.onCreate(path);

        state = LuaL.newstate();
        Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(callback_handler));
        LuaL.openlibs(state);
		Lua.register_hxtrace_func(cpp.Callable.fromStaticFunction(print_function));
		state.register_hxtrace_lib();

        luaCallbacks["__onPointerIndex"] = onPointerIndex;
        luaCallbacks["__onPointerNewIndex"] = onPointerNewIndex;
        luaCallbacks["__gc"] = onGarbageCollection;
        
        state.newmetatable("__funkinMetaTable");

        state.pushstring('__index');
        state.pushcfunction(cpp.Callable.fromStaticFunction(__index));
        state.settable(-3);
        
        state.pushstring('__newindex');
        state.pushcfunction(cpp.Callable.fromStaticFunction(__newindex));
        state.settable(-3);
    }

    public override function onLoad() {
        state.dostring(Assets.getText(path));
    }

    public static var callbackReturnVariables = [];

    public override function onCall(funcName:String, args:Array<Dynamic>):Dynamic {
        state.settop(0);
        state.getglobal(funcName);

        if (state.type(-1) != Lua.LUA_TFUNCTION)
            return null;
        
        for (k=>val in args)
            pushArg(val);

        if (state.pcall(args.length, 1, 0) != 0) {
            this.error('${state.tostring(-1)}');
            return null;
        }

        return fromLua(state.gettop());
    }

    public override function set(variable:String, value:Dynamic) {
        pushArg(value);
        state.setglobal(variable);
    }

    public override function onDestroy() {
        super.onDestroy();

        if (state != null) {
            Lua.close(state);
            state = null;
        }
    }
    public override function reload() {
        Logs.trace('Hot-reloading is currently not supported on Lua.', WARNING);
    }

    // UTILS
    #if REGION
    
    static inline function print_function(s:String) : Int {
		if (Script.curScript != null)
            Script.curScript.trace(s);
		return 0;
	}

    public function fromLua(stackPos:Int):Dynamic {
        var v:Dynamic = state.fromLua(stackPos);
        if (v is Dynamic && Reflect.hasField(v, "__stack_id")) {
            // is a "pointer"! convert it back.
            var pos:Int = Reflect.field(v, "__stack_id");
            return stack[pos];
        }
        return v;
    }
    public function pushArg(val:Dynamic) {
        switch (Type.typeof(val)) {
            case Type.ValueType.TNull:
                state.pushnil();
            case Type.ValueType.TBool:
                state.pushboolean(val);
            case Type.ValueType.TInt:
                state.pushinteger(cast(val, Int));
            case Type.ValueType.TFloat:
                state.pushnumber(val);
            case Type.ValueType.TClass(String):
                state.pushstring(cast(val, String));
            case Type.ValueType.TClass(Array):
                state.arrayToLua(val);
            case Type.ValueType.TObject:
                @:privateAccess
                state.objectToLua(val); // {}
            default:
                
                var p = {
                    __stack_id: lastStackID++,
                };
                state.toLua(p);
                state.getmetatable("__funkinMetaTable");
                state.setmetatable(-2);
        
                state.pushstring('__gc');
                state.pushcfunction(cpp.Callable.fromStaticFunction(__gc));
                state.settable(-3);

                stack[p.__stack_id] = val;
        }
    }
    public static function __index(state:StatePointer):Int {
        return callback_handler(cast cpp.Pointer.fromRaw(state).ref, "__onPointerIndex");
    }
    public static function __newindex(state:StatePointer):Int {
        return callback_handler(cast cpp.Pointer.fromRaw(state).ref, "__onPointerNewIndex");
    }
    public static function __gc(state:StatePointer):Int {
        // callbackPreventAutoConvert = true;
        var v = callback_handler(cast cpp.Pointer.fromRaw(state).ref, "__gc");
        // callbackPreventAutoConvert = false;
        return v;
    }

    public function onPointerIndex(obj:Dynamic, key:String) {
        if (obj != null)
            return Reflect.getProperty(obj, key);
        return null;
    }

    public function onPointerNewIndex(obj:Dynamic, key:String, val:Dynamic) {
        if (obj != null)
            Reflect.setProperty(obj, key, val);
    }

    public function onGarbageCollection(obj:Dynamic) {
        trace(obj);
        if (Reflect.hasField(obj, "__stack_id")) {
            trace('Clearing item ID: ${obj.__stack_id} from stack due to garbage collection');
            stack.remove(obj.__stack_id);
        }
    }
    
    private static var callbackPreventAutoConvert:Bool = false;
    public static inline function callback_handler(l:State, fname:String):Int {

        if (!(Script.curScript is LuaScript))
            return 0;
        var curLua:LuaScript = cast Script.curScript;

		var cbf = curLua.luaCallbacks.get(fname);
        callbackReturnVariables = [];
        
		if (cbf == null || !Reflect.isFunction(cbf))
			return 0;

		var nparams:Int = Lua.gettop(l);
		var args:Array<Dynamic> = callbackPreventAutoConvert ? [for(i in 0...nparams) l.fromLua(i + 1)] : [for(i in 0...nparams) curLua.fromLua(i + 1)];

		var ret:Dynamic = null;

        try {
            ret = (nparams > 0) ? Reflect.callMethod(null, cbf, args) : cbf();
        } catch(e) {
            curLua.error(e.details()); // for super cool mega logging!!!
            throw e;
        }
        Lua.settop(l, 0);

        if (callbackReturnVariables.length <= 0)
            callbackReturnVariables.push(ret);
        for(e in callbackReturnVariables)
            curLua.pushArg(e);

		/* return the number of results */
		return callbackReturnVariables.length;

	}
    #end
}
#end