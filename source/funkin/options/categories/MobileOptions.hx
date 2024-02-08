package funkin.options.categories;

import flixel.FlxG;
import lime.system.System;
import flixel.util.FlxTimer;
import funkin.backend.MusicBeatState;
import mobile.substates.MobileControlSelectSubState;

class MobileOptions extends OptionsScreen {

	var canEnter:Bool = true;

	public override function new() {
		super("Mobile", 'Change Mobile Related Things such as Controls alpha, screen timeout....');
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
		add(new Checkbox(
			"Hide Hitbox",
			"If checked, The hitbox control will not visible.",
			"hideHitbox"));
		add(new Checkbox(
			"Allow Screen Timeout",
			"If checked, The phone will enter sleep mode if the player is inactive.",
			"screenTimeOut",
			changeScreenTimeout));
	}

	override function update(elapsed) super.update(elapsed);

	function changeControlsAlpha(alpha) MusicBeatState.instance.virtualPad.alpha = alpha;
	function changeScreenTimeout(bool) System.allowScreenTimeout = bool;
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