package funkin.menus;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import funkin.backend.FunkinText;

class Warning {
	public var title: String;
	public var text: String;
	public var markerPairs: Array<Map<String, Int>>;

	public function new(Title: String, Text: String, ?MarkerPairs: Array<Map<String, Int>>) {
		title = Title;
		text = Text;
		markerPairs = MarkerPairs;
	}
}

class BetaWarningState extends MusicBeatState {
	var titleAlphabet:Alphabet;
	var disclaimer:FunkinText;

	var transitioning:Bool = false;

	var warnings: Array<Warning> = [
		new Warning("", "Null Object Reference"),
		new Warning("WARNING", "never use *haxe* for anything ever",
					[["*"] => 0xFFB700]),
		new Warning("viath be like", "*DiGear* if you're becoming a race car can I ride you",
					[["*" => 0x87A4F0]]),
		new Warning("MORBING", "This build only has *jeffrey* in it. suck my ^weewee^!",
					[["*" => 0xFFFF9241], ["^" => 0xFFFFF783]]),
		new Warning("WARNING", "you *will* have an epileptic seizure",
					[["*" => 0x43A44E]]),
		new Warning("WARNING", "*Sam*",
					[["*" => 0x680000]]),
	];

	public override function create() {
		super.create();

		var warning = warnings[FlxG.random.int(0, warnings.length - 1)];
		
		titleAlphabet = new Alphabet(0, 0, warning.title, true);
		titleAlphabet.screenCenter(X);
		add(titleAlphabet);

		disclaimer = new FunkinText(16, titleAlphabet.y + titleAlphabet.height + 10, FlxG.width - 32, warning.text, 32);
		disclaimer.alignment = CENTER;
		if (warning.markerPairs.length > 0) {
			var markers = [];
			for (markerPair in warning.markerPairs) {
				for (marker => color in markerPair) {
					markers.push(new FlxTextFormatMarkerPair(new FlxTextFormat(color), marker));
				}
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