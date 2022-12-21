package funkin.multitasking;

import flixel.FlxState;
import flixel.FlxG;

class MultiTaskingHandler {
    public static var openedWindows:Array<StateWindow> = [];

    public static function init() {
        FlxG.signals.postUpdate.add(update);
        // FlxG.signals.preDraw.add(draw);
    }

    public static function openWindow(name:String, state:MusicBeatState) {
        var window = new StateWindow(name, state);
        openedWindows.push(window);
    }

    public static function update() {
        for(window in openedWindows) {
            window.update(FlxG.elapsed);
        }
    }

    public static function draw() {
        for(window in openedWindows) {
            window.draw();
        }
    }

    public static function closeWindow(window:StateWindow) {
        openedWindows.remove(window);

        window.window.close();
        window.state.destroy();

    }
}