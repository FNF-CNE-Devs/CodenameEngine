package mobile.options.categories;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;
import funkin.backend.MusicBeatState;
import mobile.substates.MobileControlSelectSubState;
import funkin.options.OptionsScreen;
import funkin.options.Options;

class MobileOptions extends OptionsScreen {
	var canEnter:Bool = true;
	var lastStorageType:String = Options.storageType;

	public override function new() {
		dpadMode = 'LEFT_FULL';
		actionMode = 'A_B';
		super("Mobile", 'Change Mobile Related Things such as Controls alpha, screen timeout....', null, 'LEFT_FULL', 'A_B');
		add(new funkin.options.type.TextOption(
			"Mobile Controls",
			"Choose which control to play with (hitbox, vpad left, vpad right, custom...).",
			openMobileControlsMenu));
		add(new funkin.options.type.NumOption(
			"Controls Alpha",
			"Change how transparent the mobile controls should be",
			0.0, // minimum
			1.0, // maximum
			0.1, // change
			"controlsAlpha", // save name or smth
			changeControlsAlpha)); // callback
		add(new funkin.options.type.ArrayOption(
			"Hitbox Design",
			"Choose how your hitbox should look like!",
			['gradient', 'noGradient', 'hidden'],
			['Gradient', 'No Gradient', 'Hidden'],
			'hitboxType'));
		#if mobile
		add(new funkin.options.type.Checkbox(
			"Allow Screen Timeout",
			"If checked, The phone will enter sleep mode if the player is inactive.",
			"screenTimeOut"));
		#end
		#if android
		add(new funkin.options.type.ArrayOption(
			"Storage Type",
			"Test reasons",
			['EXTERNAL_DATA', 'EXTERNAL_OBB', 'EXTERNAL', 'EXTERNAL_OBB'],
			['Data', 'Obb', '.' + lime.app.Application.current.meta.get('file'), 'Media'],
			'storageType'));
		#end
	}

	override function update(elapsed) super.update(elapsed);

	override public function destroy() {
		/*Options.save();
		Options.applySettings();*/
		lime.system.System.allowScreenTimeout = Options.screenTimeOut;
		if (Options.storageType != lastStorageType) {
			funkin.backend.utils.NativeAPI.showMessageBox('Notice!', 'Storage Type has been changed and you needed restart the game!!\nPress OK to close the game.');
			lime.system.System.exit(0);
		}
	}

	function changeControlsAlpha(alpha) {
		MusicBeatState.instance.virtualPad.alpha = alpha;
		if (mobile.objects.MobileControls.mobileC) {
			FlxG.sound.volumeUpKeys = [];
			FlxG.sound.volumeDownKeys = [];
			FlxG.sound.muteKeys = [];
		} else {
			FlxG.sound.volumeUpKeys = [FlxKey.PLUS, FlxKey.NUMPADPLUS];
			FlxG.sound.volumeDownKeys = [FlxKey.MINUS, FlxKey.NUMPADMINUS];
			FlxG.sound.muteKeys = [FlxKey.ZERO, FlxKey.NUMPADZERO];
		}
	}

	function openMobileControlsMenu() {
		if(!canEnter) return;
		canEnter = false;
		FlxG.state.persistentUpdate = false;
		MusicBeatState.instance.camVPad.visible = false;
		FlxG.state.openSubState(new MobileControlSelectSubState(() -> {
			MusicBeatState.instance.camVPad.visible = true;
			FlxG.state.persistentUpdate = true;
			new FlxTimer().start(0.2, (tmr:FlxTimer) -> canEnter = true);
		}));
	}
}