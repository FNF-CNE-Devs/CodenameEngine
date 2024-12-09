package funkin.menus;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import funkin.backend.FunkinText;

class Warning {
	public var title: String;
	public var text: String;
	public var markerPairs: Map<String, Int> = [];

	public function new(Title: String, Text: String, ?MarkerPairs: Map<String, Int>) {
		title = Title;
		text = Text;
		if (MarkerPairs != null) {
			markerPairs = MarkerPairs;
		}
	}
}

class BetaWarningState extends MusicBeatState {
	var titleAlphabet:Alphabet;
	var disclaimer:FunkinText;

	var transitioning:Bool = false;

	var warnings: Array<Warning> = [
		new Warning("Error", "Null Object Reference"),
		new Warning("WARNING", "never use *haxe* for anything ever",
					["*" => 0xFFB700]),
		new Warning("viath be like", "*DiGear* if you're becoming a race car can I ride you",
					["*" => 0x87A4F0]),
		new Warning("MORBING", "This build only has *jeffrey* in it. suck my ^weewee^!",
					["*" => 0xFFFF9241, "^" => 0xFFFFF783]),
		new Warning("WARNING", "you *will* have an epileptic seizure",
					["*" => 0x43A44E]),
		new Warning("WARNING", "*Sam*",
					["*" => 0x680000]),
		new Warning("-POINT OF ADVICE-", "You can hold an extra item in the box at the top of the screen. To use it, press the SELECT button."),
		new Warning("WARNING",
					"my brother has a ver*y special atta*ck. if you see ^a blue atta^ck,
					don't move and it won't hurt you. here's an easy way to keep it
					in mind. imagine a stop sign. when you see a sign, yo&u st&op,
					right? stop signs ar&e r&ed, so imagine ^a bl^&u&^e stop sign instead.
					simple, right? when fighting, think abou&%t blue stop sig%&ns.
					remember... blue stop signs
					i cant fix the colors btw shut the fuc^k u p :)",
					["*" => 0x0000FF, "^" => 0x14A7FC, "&" => 0xFF0000, "%" => 0xFFFF00])
	];

	public override function create() {
		super.create();

		var warning = warnings[FlxG.random.int(0, warnings.length - 1)];
		
		titleAlphabet = new Alphabet(0, 0, warning.title, true);
		titleAlphabet.screenCenter(X);
		add(titleAlphabet);

		disclaimer = new FunkinText(16, titleAlphabet.y + titleAlphabet.height + 10, FlxG.width - 32, warning.text, 32);
		disclaimer.alignment = CENTER;
		if (Lambda.count(warning.markerPairs) > 0) {
			var markers = [];
				for (marker => color in warning.markerPairs) {
					markers.push(new FlxTextFormatMarkerPair(new FlxTextFormat(color), marker));
				}
			disclaimer.applyMarkup(warning.text, markers);
		}
		add(disclaimer);

		var off = Std.int((FlxG.height - (disclaimer.y + disclaimer.height)) / 2);
		disclaimer.y += off;
		titleAlphabet.y += off;

		DiscordUtil.call("onMenuLoaded", ["Beta Warning"]);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.ACCEPT && transitioning) {
			FlxG.camera.stopFX(); FlxG.camera.visible = false;
			goToTitle();
		}

		if (controls.ACCEPT && !transitioning) {
			transitioning = true;
			CoolUtil.playMenuSFX(CONFIRM);
			FlxG.camera.flash(FlxColor.WHITE, 1, function() {
				FlxG.camera.fade(FlxColor.BLACK, 2.5, false, goToTitle);
			});
		}
	}

	private function goToTitle() {
		MusicBeatState.skipTransIn = MusicBeatState.skipTransOut = true;
		FlxG.switchState(new TitleState());
	}
}