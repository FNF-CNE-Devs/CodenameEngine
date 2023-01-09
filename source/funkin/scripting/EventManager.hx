package funkin.scripting;

import funkin.scripting.events.*;

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
}