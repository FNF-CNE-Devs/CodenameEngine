package funkin.options.categories;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import lime.system.System;
import flixel.util.FlxTimer;
import funkin.backend.MusicBeatState;
import mobile.substates.MobileControlSelectSubState;

class MobileOptions extends OptionsScreen {

	var canEnter:Bool = true;

	public override function new() {
		dpadMode = 'LEFT_FULL';
		actionMode = 'A_B';
		super("Mobile", 'Change Mobile Related Things such as Controls alpha, screen timeout....', null, 'LEFT_FULL', 'A_B');
		add(new TextOption(
			"Mobile Controls",
			"Choose which control to play with (hitbox, vpad left, vpad right, custom...).",
			openMobileControlsMenu));
		add(new NumOption(
			"Controls Alpha",
			"Change how transparent the mobile controls should be",
			0.0, // minimum
			1.0, // maximum
			0.1, // change
			"controlsAlpha", // save name or smth
			changeControlsAlpha)); // callback
		add(new ArrayOption(
			"Hitbox Design",
			"Choose how your hitbox should look like!",
			['gradient', 'noGradient', 'hidden'],
			['Gradient', 'No Gradient', 'Hidden'],
			'hitboxType'));
		#if mobile
		add(new Checkbox(
			"Allow Screen Timeout",
			"If checked, The phone will enter sleep mode if the player is inactive.",
			"screenTimeOut"));
		#end
	}

	override function update(elapsed) super.update(elapsed);

	override dynamic function onClose(o:OptionsScreen) System.allowScreenTimeout = Options.screenTimeOut;

	function changeControlsAlpha(alpha) {
		MusicBeatState.instance.virtualPad.alpha = alpha;
		if (MobileControls.mobileC) {
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