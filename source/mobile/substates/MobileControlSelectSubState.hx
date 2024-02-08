package mobile.substates;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxGradient;
import mobile.backend.TouchFunctions;
import mobile.flixel.FlxButton;
import flixel.input.touch.FlxTouch;
import flixel.ui.FlxButton as UIButton;
import funkin.backend.MusicBeatSubstate;
import mobile.objects.MobileControls;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.tweens.*;
import flixel.FlxG;
import funkin.backend.assets.Paths;
import mobile.objects.PsychAlphabet;

using StringTools;

class MobileControlSelectSubState extends MusicBeatSubstate
{
	var options:Array<String> = ['Pad-Right', 'Pad-Left', 'Pad-Custom', 'Pad-Duo', 'Hitbox', 'Keyboard'];
	var control:MobileControls;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var itemText:PsychAlphabet;
	var positionText:FlxText;
	var positionTextBg:FlxSprite;
	var bg:FlxBackdrop;
	var ui:FlxCamera;
	var curOption:Int = MobileControls.mode;
	var buttonBinded:Bool = false;
	var bindButton:FlxButton;
	var reset:UIButton;
	var tweenieShit:Float = 0;
	var keyboardText:FlxText;
	var closeCallBack:Void->Void;

	public function new(?closeCallBack:Void->Void, ?openCallBack:Void->Void)
	{
		super();

		this.closeCallBack = closeCallBack;
		if(openCallBack != null) openCallBack();

		bg = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true,
			FlxColor.fromRGB(FlxG.random.int(0, 255), FlxG.random.int(0, 255), FlxG.random.int(0, 255)),
			FlxColor.fromRGB(FlxG.random.int(0, 255), FlxG.random.int(0, 255), FlxG.random.int(0, 255))));
		bg.velocity.set(40, 40);
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.45}, 0.3, {
			ease: FlxEase.quadOut,
			onComplete: (twn:FlxTween) ->
			{
				FlxTween.tween(ui, {alpha: 1}, 0.2, {ease: FlxEase.circOut});
			}
		});
		add(bg);

		ui = new FlxCamera();
		ui.bgColor.alpha = 0;
		ui.alpha = 0;
		FlxG.cameras.add(ui, false);

		itemText = new PsychAlphabet(0, 60, '');
		itemText.alignment = LEFT;
		itemText.cameras = [ui];
		add(itemText);

		leftArrow = new FlxSprite(0, itemText.y - 25);
		leftArrow.frames = Paths.getSparrowAtlas('mobile/menu/arrows');
		leftArrow.animation.addByPrefix('idle', 'arrow left');
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.cameras = [ui];
		add(leftArrow);

		itemText.x = leftArrow.width + 70;
		leftArrow.x = itemText.x - 60;

		rightArrow = new FlxSprite().loadGraphicFromSprite(leftArrow);
		rightArrow.flipX = true;
		rightArrow.setPosition(itemText.x + itemText.width + 10, itemText.y - 25);
		rightArrow.cameras = [ui];
		add(rightArrow);

		positionText = new FlxText(0, FlxG.height, FlxG.width / 4, '');
		positionText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, FlxTextAlign.LEFT);
		positionText.visible = false;

		positionTextBg = FlxGradient.createGradientFlxSprite(250, 150, [FlxColor.BLACK, FlxColor.BLACK, FlxColor.BLACK, FlxColor.TRANSPARENT], 1, 360);
		positionTextBg.setPosition(0, FlxG.height - positionTextBg.height);
		positionTextBg.visible = false;
		positionTextBg.alpha = 0.8;
		add(positionTextBg);
		positionText.cameras = [ui];
		add(positionText);

		keyboardText = new FlxText(0, 0, FlxG.width, "-- No Controls --", 14);
		keyboardText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, FlxTextAlign.CENTER);
		keyboardText.screenCenter();
		keyboardText.cameras = [ui];
		add(keyboardText);
		keyboardText.kill();

		var exit = new UIButton(0, itemText.y - 25, "Exit & Save", () ->
		{
			MobileControls.mode = curOption;
			if (options[curOption] == 'Pad-Custom')
				MobileControls.setCustomMode(control.virtualPad);
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if(closeCallBack != null) closeCallBack();
			close();
		});
		exit.color = FlxColor.LIME;
		exit.setGraphicSize(Std.int(exit.width) * 3);
		exit.updateHitbox();
		exit.x = FlxG.width - exit.width - 70;
		exit.label.setFormat(Paths.font('vcr.ttf'), 28, FlxColor.WHITE, FlxTextAlign.CENTER);
		exit.label.fieldWidth = exit.width;
		exit.label.x = ((exit.width - exit.label.width) / 2) + exit.x;
		exit.label.offset.y = -10; // WHY THE FUCK I CAN'T CHANGE THE LABEL Y
		exit.cameras = [ui];
		add(exit);

		reset = new UIButton(exit.x, exit.height + exit.y + 20, "Reset", () ->
		{
			changeOption(0); // realods the current control mode ig?
		});
		reset.color = FlxColor.RED;
		reset.setGraphicSize(Std.int(reset.width) * 3);
		reset.updateHitbox();
		reset.label.setFormat(Paths.font('vcr.ttf'), 28, FlxColor.WHITE, FlxTextAlign.CENTER);
		reset.label.fieldWidth = reset.width;
		reset.label.x = ((reset.width - reset.label.width) / 2) + reset.x;
		reset.label.offset.y = -10;
		reset.cameras = [ui];
		add(reset);

		changeOption(0);
		setOptionText();
	}

	override function update(elapsed:Float)
	{
		checkArrowButton(leftArrow, () ->
		{
			changeOption(-1);
		});

		checkArrowButton(rightArrow, () ->
		{
			changeOption(1);
		});

		if (options[curOption] == 'Pad-Custom')
		{
			if (buttonBinded)
			{
				if (TouchFunctions.touchJustReleased)
				{
					bindButton = null;
					buttonBinded = false;
				}
				else
					moveButton(TouchFunctions.touch, bindButton);
			}
			else
			{
				control.virtualPad.forEachAlive((button:FlxButton) ->
				{
					if (button.justPressed)
						moveButton(TouchFunctions.touch, button);
				});
			}
		}

		tweenieShit += 180 * elapsed;
		keyboardText.alpha = 1 - Math.sin((Math.PI * tweenieShit) / 180);

		super.update(elapsed);
	}

	function changeControls(?type:Int = null)
	{
		if (type == null)
			type = curOption;
		if (control != null)
			control.destroy();
		if (members.contains(control))
			remove(control);
		control = new MobileControls(type);
		add(control);
		control.cameras = [ui];
	}

	function changeOption(change:Int)
	{
		curOption += change;

		if (curOption < 0)
			curOption = options.length - 1;
		if (curOption >= options.length)
			curOption = 0;

		switch (curOption)
		{
			case 0 | 1 | 3:
				reset.visible = false;
				keyboardText.kill();
				changeControls();
			case 2:
				reset.visible = true;
				keyboardText.kill();
				changeControls();
			case 4:
				reset.visible = false;
				keyboardText.kill();
				changeControls();
			case 5:
				reset.visible = false;
				keyboardText.revive();
				changeControls();
		}
		updatePosText();
		setOptionText();
	}

	function setOptionText()
	{
		itemText.text = options[curOption].replace('-', ' ');
		itemText.updateHitbox();
		itemText.offset.set(0, 15);
		FlxTween.tween(rightArrow, {x: itemText.x + itemText.width + 10}, 0.1, {ease: FlxEase.quintOut});
	}

	function updatePosText()
	{
		var optionName = options[curOption];
		if (optionName == 'Pad-Custom')
		{
			positionText.visible = positionTextBg.visible = true;
			positionText.text = 'LEFT X: ${control.virtualPad.buttonLeft.x} - Y: ${control.virtualPad.buttonLeft.y}\nDOWN X: ${control.virtualPad.buttonDown.x} - Y: ${control.virtualPad.buttonDown.y}\n\nUP X: ${control.virtualPad.buttonUp.x} - Y: ${control.virtualPad.buttonUp.y}\nRIGHT X: ${control.virtualPad.buttonRight.x} - Y: ${control.virtualPad.buttonRight.y}';
			positionText.setPosition(0, (((positionTextBg.height - positionText.height) / 2) + positionTextBg.y));
		}
		else
			positionText.visible = positionTextBg.visible = false;
	}

	function checkArrowButton(button:FlxSprite, func:Void->Void)
	{
		if (TouchFunctions.touchOverlapObject(button))
		{
			if (TouchFunctions.touchPressed)
				button.animation.play('press');
			if (TouchFunctions.touchJustPressed)
				func();
		}
		if (TouchFunctions.touchJustReleased && button.animation.curAnim.name == 'press')
			button.animation.play('idle');
		if (FlxG.keys.justPressed.LEFT && button == leftArrow || FlxG.keys.justPressed.RIGHT && button == rightArrow)
			func();
	}

	function moveButton(touch:FlxTouch, button:FlxButton):Void
	{
		bindButton = button;
		buttonBinded = bindButton == null ? false : true;
		bindButton.x = touch.x - Std.int(bindButton.width / 2);
		bindButton.y = touch.y - Std.int(bindButton.height / 2);
		updatePosText();
	}
}