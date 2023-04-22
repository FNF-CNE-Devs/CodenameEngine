package funkin.backend.scripting;

import funkin.backend.scripting.events.CancellableEvent;
import funkin.backend.system.Conductor;
import flixel.FlxState;
import funkin.backend.assets.ModsFolder;
#if GLOBAL_SCRIPT
/**
 * Class for THE Global Script, aka script that runs in the background at all times.
 */
class GlobalScript {
	public static var script:Script;

	public static function init() {
		#if MOD_SUPPORT
		ModsFolder.onModSwitch.add(onModSwitch);
		#end

		Conductor.onBeatHit.add(beatHit);
		Conductor.onStepHit.add(stepHit);

		FlxG.signals.focusGained.add(function() {
			call("focusGained");
		});
		FlxG.signals.focusLost.add(function() {
			call("focusLost");
		});
		FlxG.signals.gameResized.add(function(w:Int, h:Int) {
			call("gameResized", [w, h]);
		});
		FlxG.signals.postDraw.add(function() {
			call("postDraw");
		});
		FlxG.signals.postGameReset.add(function() {
			call("postGameReset");
		});
		FlxG.signals.postGameStart.add(function() {
			call("postGameStart");
		});
		FlxG.signals.postStateSwitch.add(function() {
			call("postStateSwitch");
		});
		FlxG.signals.postUpdate.add(function() {
			call("postUpdate", [FlxG.elapsed]);
			if (FlxG.keys.justPressed.F5) {
				if (script != null && !(script is DummyScript)) {
					Logs.trace('Reloading global script...', WARNING, YELLOW);
					script.reload();
					Logs.trace('Global script successfully reloaded.', WARNING, GREEN);
				} else {
					Logs.trace('Loading global script...', WARNING, YELLOW);
					onModSwitch(#if MOD_SUPPORT ModsFolder.currentModFolder #else null #end);
					if (script is DummyScript)
						Logs.trace('Global script not found. Are you sure "data/global.hx" exists?', ERROR, RED);
					else
						Logs.trace('Global script successfully loaded.', WARNING, GREEN);
				}
			}
		});
		FlxG.signals.preDraw.add(function() {
			call("preDraw");
		});
		FlxG.signals.preGameReset.add(function() {
			call("preGameReset");
		});
		FlxG.signals.preGameStart.add(function() {
			call("preGameStart");
		});
		FlxG.signals.preStateCreate.add(function(state:FlxState) {
			call("preStateCreate", [state]);
		});
		FlxG.signals.preStateSwitch.add(function() {
			call("preStateSwitch", []);
		});
		FlxG.signals.preUpdate.add(function() {
			call("preUpdate", [FlxG.elapsed]);
			call("update", [FlxG.elapsed]);
		});

		onModSwitch(#if MOD_SUPPORT ModsFolder.currentModFolder #else null #end);
	}

	public static function event<T:CancellableEvent>(name:String, event:T):T {
		if (script == null) return event;
		script.call(name, [event]);
		return event;
	}

	public static function call(name:String, ?args:Array<Dynamic>) {
		if (script == null) return;
		script.call(name, args);
	}
	public static function onModSwitch(newMod:String) {
		call("onDestroy");
		if (script != null) {
			script.destroy();
			script = null;
		}
		script = Script.create(Paths.script('data/global'));
		script.load();
	}

	public static function beatHit(curBeat:Int) {
		call("beatHit", [curBeat]);
	}

	public static function stepHit(curStep:Int) {
		call("stepHit", [curStep]);
	}
}
#end