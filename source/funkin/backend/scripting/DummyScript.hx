package funkin.backend.scripting;

/**
 * Simple class for empty scripts or scripts whose language isn't imported yet.
 */
class DummyScript extends Script {
	public var variables:Map<String, Dynamic> = [];
	
	public override function get(v:String) {return variables.get(v);}
	public override function set(v:String, v2:Dynamic) {return variables.set(v, v2);}
	public override function onCall(method:String, parameters:Array<Dynamic>):Dynamic {
		var func = variables.get(method);
		if (Reflect.isFunction(func))
			return (parameters != null && parameters.length > 0) ? Reflect.callMethod(null, func, parameters) : func();

		return null;
	}
}