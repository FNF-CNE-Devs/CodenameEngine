package funkin.system;

import flixel.FlxState;
import flixel.FlxGame;

class FunkinGame extends FlxGame {
    public function new(gameWidth = 0, gameHeight = 0, ?initialState:Class<FlxState>, updateFramerate = 60, drawFramerate = 60, skipSplash = false, startFullscreen = false) {
        super(gameWidth, gameHeight, initialState, 1, updateFramerate, drawFramerate, skipSplash, startFullscreen);
        #if (cpp && ENABLE_PROFILER)
            cpp.vm.Profiler.start('./profiler.txt');
        #end
    }
}