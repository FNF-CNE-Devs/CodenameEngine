package funkin.backend.scripting;

import flixel.FlxState;
import funkin.backend.scripting.events.*;

class EventManager {
	// map doesnt work for that
	public static var eventValues:Array<CancellableEvent> = [];
	public static var eventKeys:Array<Class<CancellableEvent>> = [];

	public static function get<T:CancellableEvent>(cl:Class<T>):T {
		var c:Class<CancellableEvent> = cast cl;

		var index = eventKeys.indexOf(c);
		if (index < 0) {
			eventKeys.push(c);
			eventValues.push(Type.createInstance(c, []));
			return cast eventValues.last();
		}

		return cast eventValues[index];
	}

	public static function reset() {
		for(v in eventValues)
			v.destroy();
		eventValues = [];
		eventKeys = [];
	}

	public static function init() {
		FlxG.signals.preStateCreate.add(onStateSwitch);
	}

	private static inline function onStateSwitch(newState:FlxState)
		reset();
}