package funkin.scripting;

#if ENABLE_LUA
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
import llua.Macro.*;
import haxe.DynamicAccess;

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
        luaCallbacks["__onPointerCall"] = onPointerCall;
        luaCallbacks["__gc"] = onGarbageCollection;
        
        state.newmetatable("__funkinMetaTable");

        state.pushstring('__index');
        state.pushcfunction(cpp.Callable.fromStaticFunction(__index));
        state.settable(-3);
        
        state.pushstring('__newindex');
        state.pushcfunction(cpp.Callable.fromStaticFunction(__newindex));
        state.settable(-3);
        
        state.pushstring('__call');
        state.pushcfunction(cpp.Callable.fromStaticFunction(__call));
        state.settable(-3);

        state.setglobal("__funkinMetaTable");
    }

    public override function onLoad() {
        if (state.dostring(Assets.getText(path)) != 0)
            this.error('${state.tostring(-1)}');
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

        var v = fromLua(state.gettop());
        state.settop(0);
        return v;
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
		var ret:Any = null;

        switch(state.type(stackPos)) {
			case Lua.LUA_TNIL:
				ret = null;
			case Lua.LUA_TBOOLEAN:
				ret = state.toboolean(stackPos);
			case Lua.LUA_TNUMBER:
				ret = state.tonumber(stackPos);
			case Lua.LUA_TSTRING:
				ret = state.tostring(stackPos);
			case Lua.LUA_TTABLE:
				ret = toHaxeObj(stackPos);
			case Lua.LUA_TFUNCTION:
				null; // no support for functions yet
			// case Lua.LUA_TUSERDATA:
			// 	ret = LuaL.ref(l, Lua.LUA_REGISTRYINDEX);
			// 	trace("userdata\n");
			// case Lua.LUA_TLIGHTUSERDATA:
			// 	ret = LuaL.ref(l, Lua.LUA_REGISTRYINDEX);
			// 	trace("lightuserdata\n");
			// case Lua.LUA_TTHREAD:
			// 	ret = null;
			// 	trace("thread\n");
			case idk:
				ret = null;
				trace("return value not supported\n"+Std.string(idk)+" - "+stackPos);
		}


        if (ret is Dynamic && Reflect.hasField(ret, "__stack_id")) {
            // is a "pointer"! convert it back.
            var pos:Int = Reflect.field(ret, "__stack_id");
            return stack[pos];
        }
        return ret;
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
                var arr:Array<Any> = cast val;
                var size:Int = arr.length;
                state.createtable(size, 0);

                for (i in 0...size) {
                    state.pushnumber(i + 1);
                    pushArg(arr[i]);
                    state.settable(-3);
                }
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
    public static function __call(state:StatePointer):Int {
        return callback_handler(cast cpp.Pointer.fromRaw(state).ref, "__onPointerCall");
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

    public function onPointerCall(obj:Dynamic, ...args:Any) {
        trace(obj);
        trace(args);
        if (obj != null && Reflect.isFunction(obj))
            return Reflect.callMethod(null, obj, args.toArray());
        return null;
    }

    public function onPointerNewIndex(obj:Dynamic, key:String, val:Dynamic) {
        if (key == "__gc") return null;

        if (obj != null)
            Reflect.setProperty(obj, key, val);
        return null;
    }

    public function onGarbageCollection(obj:Dynamic) {
        trace(obj);
        if (Reflect.hasField(obj, "__stack_id")) {
            trace('Clearing item ID: ${obj.__stack_id} from stack due to garbage collection');
            stack.remove(obj.__stack_id);
        }
    }
    
    private static var callbackPreventAutoConvert:Bool = false;
    public static function callback_handler(l:State, fname:String):Int {

        if (!(Script.curScript is LuaScript))
            return 0;
        var curLua:LuaScript = cast Script.curScript;

		var cbf = curLua.luaCallbacks.get(fname);
        callbackReturnVariables = [];
        
		if (cbf == null || !Reflect.isFunction(cbf))
			return 0;

		var nparams:Int = Lua.gettop(l);
		var args:Array<Dynamic> = callbackPreventAutoConvert ? [for(i in 0...nparams) l.fromLua(-nparams + i)] : [for(i in 0...nparams) curLua.fromLua(-nparams + i)];

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

    public function toHaxeObj(i:Int):Any {
		var count = 0;
		var array = true;

		loopTable(state, i, {
			if(array) {
				if(Lua.type(state, -2) != Lua.LUA_TNUMBER) array = false;
				else {
					var index = Lua.tonumber(state, -2);
					if(index < 0 || Std.int(index) != index) array = false;
				}
			}
			count++;
		});

		return
		if(count == 0) {
			{};
		} else if(array) {
			var v = [];
			loopTable(state, i, {
				var index = Std.int(Lua.tonumber(state, -2)) - 1;
				v[index] = fromLua(-1);
			});
			cast v;
		} else {
			var v:DynamicAccess<Any> = {};
			loopTable(state, i, {
				switch Lua.type(state, -2) {
					case t if(t == Lua.LUA_TSTRING): v.set(Lua.tostring(state, -2), fromLua(-1));
					case t if(t == Lua.LUA_TNUMBER):v.set(Std.string(Lua.tonumber(state, -2)), fromLua(-1));
				}
			});
			cast v;
		}
	}
    #end
}
#end