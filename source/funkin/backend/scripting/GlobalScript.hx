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
	public static var scripts:ScriptPack;

	public static function init() {
		#if MOD_SUPPORT
		ModsFolder.onModSwitch.add(onModSwitch);
		#end

		Conductor.onBeatHit.add(beatHit);
		Conductor.onStepHit.add(stepHit);

		FlxG.signals.focusGained.add(function() {
			scripts.call("focusGained");
		});
		FlxG.signals.focusLost.add(function() {
			scripts.call("focusLost");
		});
		FlxG.signals.gameResized.add(function(w:Int, h:Int) {
			scripts.call("gameResized", [w, h]);
		});
		FlxG.signals.postDraw.add(function() {
			scripts.call("postDraw");
		});
		FlxG.signals.postGameReset.add(function() {
			scripts.call("postGameReset");
		});
		FlxG.signals.postGameStart.add(function() {
			scripts.call("postGameStart");
		});
		FlxG.signals.postStateSwitch.add(function() {
			scripts.call("postStateSwitch");
		});
		FlxG.signals.postUpdate.add(function() {
			scripts.call("postUpdate", [FlxG.elapsed]);
			if (FlxG.keys.justPressed.F5) {
				if (scripts != null) {
					Logs.trace('Reloading global script...', WARNING, YELLOW);
					scripts.reload();
					Logs.trace('Global script successfully reloaded.', WARNING, GREEN);
				} else {
					Logs.trace('Loading global script...', WARNING, YELLOW);
					onModSwitch(#if MOD_SUPPORT ModsFolder.currentModFolder #else null #end);
					if (scripts is DummyScript)
						Logs.trace('Global script not found. Are you sure "data/global.hx" exists?', ERROR, RED);
					else
						Logs.trace('Global script successfully loaded.', WARNING, GREEN);
				}
			}
		});
		FlxG.signals.preDraw.add(function() {
			scripts.call("preDraw");
		});
		FlxG.signals.preGameReset.add(function() {
			scripts.call("preGameReset");
		});
		FlxG.signals.preGameStart.add(function() {
			scripts.call("preGameStart");
		});
		FlxG.signals.preStateCreate.add(function(state:FlxState) {
			scripts.call("preStateCreate", [state]);
		});
		FlxG.signals.preStateSwitch.add(function() {
			scripts.call("preStateSwitch", []);
		});
		FlxG.signals.preUpdate.add(function() {
			scripts.call("preUpdate", [FlxG.elapsed]);
			scripts.call("update", [FlxG.elapsed]);
		});

		onModSwitch(#if MOD_SUPPORT ModsFolder.currentModFolder #else null #end);
	}

	public static function onModSwitch(newMod:String) {
		scripts.call("onDestroy");
		scripts = FlxDestroyUtil.destroy(scripts);
		scripts = new ScriptPack("global");
		var scriptPaths = [for (i in Paths.getFolderContent('data', true)) if (i.contains("/global.")) i];
		for (i in Paths.getFolderContent('data/global', true)) scriptPaths.push(i);
		for (i in scriptPaths) scripts.add(Script.create(Paths.script(i)));
		scripts.load();
	}

	public static function beatHit(curBeat:Int) {
		scripts.call("beatHit", [curBeat]);
	}

	public static function stepHit(curStep:Int) {
		scripts.call("stepHit", [curStep]);
	}
}
#end