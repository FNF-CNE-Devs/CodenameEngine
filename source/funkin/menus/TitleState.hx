package funkin.menus;

import flixel.util.typeLimit.OneOfThree;
import flixel.util.typeLimit.OneOfTwo;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.system.Conductor;
import openfl.Assets;
import funkin.ui.Alphabet;
import haxe.xml.Access;

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	public var curWacky:Array<String> = [];

	public var blackScreen:FlxSprite;
	public var textGroup:FlxGroup;
	public var ngSpr:FlxSprite;

	public var wackyImage:FlxSprite;

	override public function create():Void
	{
		curWacky = FlxG.random.getObject(getIntroTextShit());

		FlxTransitionableState.skipNextTransIn = true;
		
		super.create();

		startIntro();
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (!initialized)
			CoolUtil.playMenuSong(true);

		persistentUpdate = true;

		loadXML();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blackScreen);

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		add(textGroup);
	}

	public function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('titlescreen/introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.F)  FlxG.fullscreen = !FlxG.fullscreen;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			CoolUtil.playMenuSFX(1, 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.switchState(new MainMenuState());
			});
		}

		if (pressedEnter && !skippedIntro)
			skipIntro();

		super.update(elapsed);
	}

	public function createCoolText(textArray:Array<String>)
	{
		for (i=>text in textArray)
		{
			if (text == "" || text == null) continue;
			var money:Alphabet = new Alphabet(0, (i * 60) + 200, text, true, false);
			money.screenCenter(X);
			textGroup.add(money);
		}
	}

	public function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, (textGroup.length * 60) + 200, text, true, false);
		coolText.screenCenter(X);
		textGroup.add(coolText);
	}

	public function deleteCoolText()
	{
		while (textGroup.members.length > 0) textGroup.remove(textGroup.members[0], true);
	}

	override function beatHit(curBeat:Int)
	{
		super.beatHit(curBeat);

		logoBl.animation.play('bump');
		danceLeft = !danceLeft;

		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');

		#if TITLESCREEN_XML
		if (curBeat >= titleLength || skippedIntro) {
			if (!skippedIntro) skipIntro();
			return;
		}
		var introText = titleLines[curBeat];
		if (introText != null)
			introText.show();
		#else
		switch (curBeat)
		{
			case 1:		createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			case 3:		addMoreText('present');
			case 4:		deleteCoolText();
			case 5:		createCoolText(['In association', 'with']);
			case 7:		addMoreText('newgrounds');	ngSpr.visible = true;
			case 8:		deleteCoolText();			ngSpr.visible = false;
			case 9:		createCoolText([curWacky[0]]);
			case 11:	addMoreText(curWacky[1]);
			case 12:	deleteCoolText();
			case 13:	addMoreText('Friday');
			case 14:	addMoreText('Night');
			case 15:	addMoreText('Funkin');
			case 16:	skipIntro();
		}
		#end
	}

	#if TITLESCREEN_XML
	public var xml:Access;
	public var titleLength:Int = 16;
	public var titleLines:Map<Int, IntroText> = [
		1 => new IntroText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']),
		3 => new IntroText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er', 'present']),
		4 => new IntroText(),
		5 => new IntroText(['In association', 'with']),
		7 => new IntroText(['In association', 'with', 'newgrounds', {
			name: "newgroundsLogo",
			path: "titlescreen/newgrounds_logo",
			scale: 0.8
		}]),
		8 => new IntroText(),
		9 => new IntroText(["{introText1}"]),
		11 => new IntroText(["{introText1}", "{introText2}"]),
		12 => new IntroText(),
		13 => new IntroText(['Friday']),
		14 => new IntroText(['Friday', 'Night']),
		15 => new IntroText(['Friday', 'Night', "Funkin'"]),
	];

	public function loadXML() {
		try {
			xml = new Access(Xml.parse(Assets.getText(Paths.xml('titlescreen/titlescreen'))).firstElement());
			if (xml.hasNode.intro) {
				titleLines = [];
				if (xml.node.intro.has.length) titleLength = CoolUtil.getDefault(Std.parseInt(xml.node.intro.att.length), 16);
				for(text in xml.node.intro.nodes.text) {
					var beat:Int = CoolUtil.getDefault(text.has.beat ? Std.parseInt(text.att.beat) : null, 0);
					var texts:Array<OneOfTwo<String, TitleStateImage>> = [];
					for(e in text.elements) {
						switch(e.name) {
							case "line":
								if (!e.has.text) continue;
								texts.push(e.att.text);
							case "introtext":
								if (!e.has.line) continue;
								texts.push('{introText${e.att.line}}');
							case "sprite":
								if (!e.has.path) continue;
								var name:String = e.has.name ? e.att.name : null;
								var path:String = e.att.path;
								var flipX:Bool = e.has.flipX ? e.att.flipX == "true" : false;
								var flipY:Bool = e.has.flipY ? e.att.flipY == "true" : false;
								var scale:Float = e.has.scale ? CoolUtil.getDefault(Std.parseFloat(e.att.scale), 1) : 1;
								texts.push({
									name: name,
									path: path,
									flipX: flipX,
									flipY: flipY,
									scale: scale
								});
						}
					}
					titleLines[beat] = new IntroText(texts);
				}
			}
		} catch(e) {
            Logs.trace('Failed to load titlescreen XML: $e', ERROR);
		}
	}
	#end

	var skippedIntro:Bool = false;

	public function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(blackScreen);
			blackScreen.destroy();
			remove(textGroup);
			skippedIntro = true;
		}
	}
}

class IntroText {
	public var lines:Array<OneOfTwo<String, TitleStateImage>> = [];

	public function new(?lines:Array<OneOfTwo<String, TitleStateImage>>) {
		this.lines = lines;
	}

	public function show() {
		var state = cast(FlxG.state, TitleState);
		state.deleteCoolText();
		if (lines == null) return;
		for(e in lines) {
			if (e is String) {
				var text = cast(e, String);
				for(k=>e in state.curWacky) text = text.replace('{introText${k+1}', e);
				state.addMoreText(text);
			} else if (e is Dynamic) {
				var image:TitleStateImage = e;
				if (image.path == null) continue;

				var scale:Float = CoolUtil.getDefault(image.scale, 1);

				var sprite = new FlxSprite(0, 200, Paths.image(image.path));
				sprite.flipX = CoolUtil.getDefault(image.flipX, false);
				sprite.flipY = CoolUtil.getDefault(image.flipY, false);
				sprite.scale.set(scale, scale);
				sprite.updateHitbox();
				sprite.screenCenter(X);
				state.textGroup.add(sprite);
			}
		}
	}
}

typedef TitleStateImage = {
	var name:String;
	var path:String;
	@:optional var scale:Null<Float>;
	@:optional var flipX:Null<Bool>;
	@:optional var flipY:Null<Bool>;
}