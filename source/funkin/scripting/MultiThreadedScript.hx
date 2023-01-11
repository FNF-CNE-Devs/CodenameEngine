package funkin.scripting;

#if ALLOW_MULTITHREADING
import sys.thread.Thread;
import flixel.util.FlxDestroyUtil;
#end

import hscript.IHScriptCustomBehaviour;

class MultiThreadedScript implements IFlxDestroyable implements IHScriptCustomBehaviour {
    var thread:#if ALLOW_MULTITHREADING Thread #else Dynamic #end;

    /**
     * Script being ran.
     */
    public var script:Script;

    private var __variables:Array<String>;

    /**
     * Return value of the last call.
     */
    public var returnValue:Dynamic = null;

    /**
     * Whenever the current call has ended.
     */
    public var callEnded:Bool = true;



    public function new(path:String, ?parentScript:Script) {
        script = Script.create(path);

        if (parentScript != null) {
            if (script is HScript && parentScript is HScript) {
                var hscript = cast(script, HScript);
                var parentHScript = cast(parentScript, HScript);

                hscript.interp.variables = parentHScript.interp.variables;
                hscript.interp.publicVariables = parentHScript.interp.publicVariables;
                hscript.interp.staticVariables = parentHScript.interp.staticVariables;

                script.setParent(parentHScript.interp.scriptObject);
            }
        }

        script.load();

        thread = Thread.createWithEventLoop(function() {
            // Prevent the thread from being auto deleted
            Thread.current().events.promise();
        });

        __variables = Type.getInstanceFields(Type.getClass(this));
    }

    public inline function hget(name:String):Dynamic
        return __variables.contains(name) ? Reflect.getProperty(this, name) : script.get(name);

    public inline function hset(name:String, val:Dynamic):Dynamic {
        if (__variables.contains(name))
            Reflect.setProperty(this, name, val);
        else
            script.set(name, val);
        return val;
    }

    public function call(func:String, args:Array<Dynamic>) {
        thread.events.run(function() {
            callEnded = false;
            returnValue = script.call(func, args);
            callEnded = true;
        });
    }

    public function destroy() {
        if (script != null) {
            script.call("onDestroy");
            script.destroy();
        }

        if (thread != null) {
            thread.events.runPromised(function() {
                // close the thing
            });
        }
    }
}