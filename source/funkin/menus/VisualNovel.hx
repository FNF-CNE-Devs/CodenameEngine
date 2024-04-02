package funkin.menus;

import flixel.addons.text.FlxTypeText;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.util.FlxStringUtil;
import haxe.Exception;
import haxe.xml.Access;
import flixel.math.FlxRect;

using StringTools;

class VisualNovel extends MusicBeatState {
	public static var allowInput = true;

	var entries:Array<Entry> = [];
	var characterMap:Map<String, CharInfo> = [];
	var redirectMap:Map<String, Int> = [];

	var currentEntryId:Int = 0;
	var currentEntry(get, never):Entry;
	function get_currentEntry() {
		return entries[currentEntryId];
	}

	function next() @:privateAccess {
		if (text._typing) {
			text.skip();
			return;
		}

		if(currentEntry.next != null) {
			currentEntryId = redirectMap[currentEntry.next];
		} else {
			currentEntryId++;
			if(currentEntryId == entries.length)
				currentEntryId = 0;
		}

		showEntry();
	}

	var totalChoices = 0;

	override function create() {
		super.create();

		allowInput = true;

		FlxG.sound.playMusic("assets/images/vn/senpaimusic.ogg", 0);
		FlxG.sound.music.fadeIn(1, 0, 0.8);

		flixel.text.Uwuifier.disableUWU = true;

		var plainXML = Assets.getText("assets/images/vn/vn.xml");

		var vxml = Xml.parse(plainXML).firstElement();
		if (vxml == null)
			throw new Exception("Missing \"vn\" node in XML.");
		var xml = new Access(vxml);

		var backgrounds = [];
		var characters = [];

		for(char in xml.elements) {
			if(char.name == "character") {
				var c = new CharInfo();
				c.id = char.att.id;

				c.name = char.node.name.innerData;
				c.color = FlxColor.fromString("#" + char.node.color.innerData);
				c.image = char.node.image.innerData;
				c.scale = Std.parseFloat(char.node.scale.innerData);
				c.side = char.hasNode.side ? char.node.side.innerData : "left";
				if(char.hasNode.offset) {
					var aa = char.node.offset.innerData.split(",");
					c.offsetX = Std.parseFloat(aa[0]);
					c.offsetY = Std.parseFloat(aa[1]);
				}

				characters.push(c);
				characterMap.set(c.id, c);
			}
		}

		var i = 0;
		for(entry in xml.elements) {
			if(entry.name != "entry") continue;

			//trace(entry);

			var e = new Entry();
			e.bg = entry.has.bg ? entry.att.bg : null;
			e.character = entry.has.character ? entry.att.character : null;
			e.id = entry.has.id ? entry.att.id : null;
			e.next = entry.has.next ? entry.att.next : null;

			if(e.id != null) {
				redirectMap[e.id] = i;
			}

			if(e.bg != null && !backgrounds.contains(e.bg)) {
				backgrounds.push(e.bg);
			}
			if(e.character != null && !characterMap.exists(e.character)) {
				throw "Missing Character XML Code " + e.character;
			}

			var _entry:Xml = cast entry;

			e.text = _entry.firstChild().nodeValue.trim().replace("\r\n", "\n");

			var choices = [];

			for(choice in entry.nodes.choice) {
				var c = new Choice();
				c.text = choice.innerData.trim();
				c.redirect = choice.has.id ? choice.att.id : null;

				choices.push(c);
			}

			if(choices.length > totalChoices)
				totalChoices = choices.length;

			e.choices = choices;

			entries.push(e);
			i++;
		}

		/*trace("");
		trace("");
		trace("");

		for(entry in entries) {
			trace(entry);
		}*/

		grpBackgrounds = new FlxTypedGroup<FlxSprite>();
		for(bg in backgrounds) {
			var b = new FlxSprite(Paths.image("vn/bgs/" + bg));
			b.alpha = 0.00001;
			b.setGraphicSize(FlxG.width);
			b.antialiasing = true;
			b.screenCenter();
			b.active = false;
			grpBackgrounds.add(b);

			bgMap.set(bg, b);
		}
		add(grpBackgrounds);

		var COCK = 230;

		grpPortraits = new FlxTypedGroup<FlxSprite>();
		for(char in characters) {
			var b = new FlxSprite(Paths.image("vn/portraits/" + char.image));
			b.alpha = 0.00001;
			b.y = FlxG.height - b.height;
			if(char.side == "right") {
				b.x = FlxG.width - b.width;
				b.x -= 100;
				b.origin.set(b.frameWidth, b.frameHeight);
			} else if(char.side == "center") {
				b.screenCenter(X);
			} else {
				b.x = 0;
				b.x += 100;
				b.origin.set(0, b.frameHeight);
			}
			b.y -= COCK;
			b.x += char.offsetX;
			b.y += char.offsetY;
			b.scale.set(char.scale, char.scale);
			b.antialiasing = true;
			grpPortraits.add(b);

			chMap.set(char.id, b);
		}
		add(grpPortraits);

		var fade = new FlxSprite(Paths.image("vn/box"));
		fade.setGraphicSize(FlxG.width, fade.frameHeight);
		fade.updateHitbox();
		fade.screenCenter();
		fade.antialiasing = true;
		fade.y = FlxG.height - fade.height;
		//fade.origin.set(fade.origin.x, fade.frameHeight);
		//fade.scale.y *= 0.4;
		add(fade);

		fade.y -= COCK;

		var box = new FlxSprite().makeSolid(FlxG.width, COCK, FlxColor.BLACK);
		box.y = FlxG.height - box.height;
		add(box);

		grpChoices = new FlxTypedGroup<ChoiceButton>();
		for(i in 0...totalChoices) {
			var b = new ChoiceButton();
			//b.alpha = 0.00001;
			b.exists = false;
			//b.y = FlxG.height - b.height;
			b.redirectID = 0;
			b.onSelected = () -> {
				if(b.redirectID == -99) {
					exit();
				} else {
					currentEntryId = b.redirectID;
					showEntry();
				}
			}
			grpChoices.add(b);
		}
		add(grpChoices);

		name = new FlxText(30, 500 - 60, FlxG.width - 40, "", 32);
		name.font = Paths.font("fnf.ttf");
		name.bold = true;
		name.antialiasing = true;
		add(name);

		text = new FlxTypeText(30, 500, FlxG.width - 40, "", 32);
		text.font = Paths.font("fnf.ttf");
		text.bold = true;
		text.antialiasing = true;
		text.sounds = [FlxG.sound.load("assets/images/vn/sound_13.wav", 0.6)];
		add(text);

		showEntry();
	}

	var chMap:Map<String, FlxSprite> = [];
	var bgMap:Map<String, FlxSprite> = [];
	var grpBackgrounds:FlxTypedGroup<FlxSprite>;
	var grpPortraits:FlxTypedGroup<FlxSprite>;
	var grpChoices:FlxTypedGroup<ChoiceButton>;
	var text:FlxTypeText;
	var name:FlxText;

	function showEntry(instant:Bool = false) {
		var entry = currentEntry;

		// bg
		for(bg=>spr in bgMap) {
			FlxTween.cancelTweensOf(spr);
			FlxTween.tween(spr, {alpha: 0.00001}, 0.3);
		}

		if(entry.bg != null) {
			var bg = bgMap[entry.bg];
			FlxTween.cancelTweensOf(bg);
			FlxTween.tween(bg, {alpha: 1}, 0.3);
		}

		// character
		for(ch=>spr in chMap) {
			FlxTween.cancelTweensOf(spr);
			FlxTween.tween(spr, {alpha: 0.00001}, 0.3);
		}

		if(entry.character != null) {
			var ch = chMap[entry.character];
			FlxTween.cancelTweensOf(ch);
			FlxTween.tween(ch, {alpha: 1}, 0.3);
		}

		grpChoices.forEach(spr -> {
			spr.exists = false;
		});

		//var offset = totalChoices - entry.choices.length;

		var i = 0;
		for(choice in entry.choices) {
			var spr = grpChoices.members[i];

			spr.exists = true;
			spr.text.text = choice.text;
			spr.redirectID = choice.redirect != null ? redirectMap[choice.redirect] : currentEntryId + 1;
			if(choice.redirect == "exit")
				spr.redirectID = -99;
			spr.y = 100 + 80 * (i/* + offset*/);

			i++;
		}

		//trace(characterMap);
		//trace(entry.character);

		if(entry.character != null) {
			var charInfo = characterMap.get(entry.character);

			name.text = charInfo.name;
			name.color = charInfo.color;
			name.exists = true;
		} else {
			name.exists = false;
		}

		//text.text = entry.text;

		text.resetText(entry.text);
		text.start(0.04, true);
		dialogueEnded = false;


		grpChoices.forEach(spr -> {
			spr.active = spr.visible = false;
		});

		text.completeCallback = function() {
			dialogueEnded = true;

			grpChoices.forEach(spr -> {
				spr.active = spr.visible = true;
			});
		};
	}

	var dialogueEnded:Bool = false;

	function exit() {
		flixel.text.Uwuifier.disableUWU = false;
		FlxG.switchState(new MainMenuState());
		FlxG.sound.music.stop();
		CoolUtil.playMenuSong();
		//FlxG.sound.music.fadeOut(1, 0, function(_) {
		//	FlxG.sound.music.stop();
		//});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		FlxG.mouse.visible = true;

		if(allowInput) {
			if((FlxG.mouse.justPressed || controls.ACCEPT) && currentEntry.choices.length == 0) {
				next();
			}
		}

		if(controls.BACK) {
			exit();
		}

		allowInput = true;
	}
}

class CharInfo {
	public var id:String = "";
	public var name:String = "";
	public var image:String = "";
	public var color:FlxColor;
	public var scale:Float = 1;
	public var side:String = "";
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public function new() {

	}

	public function toString() {
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("id", id),
			LabelValuePair.weak("name", name),
			LabelValuePair.weak("image", image),
			LabelValuePair.weak("color", color),
			LabelValuePair.weak("scale", scale),
			LabelValuePair.weak("side", side),
		]);
	}
}

class Entry {
	public var id:Null<String> = "";
	public var character:String = "";
	public var bg:Null<String> = "";
	public var next:String = "";

	public var text:String = "";

	public var choices:Array<Choice> = [];

	public function new() {

	}

	public function toString() {
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("id", id),
			LabelValuePair.weak("character", character),
			LabelValuePair.weak("bg", bg),
			LabelValuePair.weak("next", next),
			LabelValuePair.weak("choices", choices),
		]);
	}
}

class Choice {
	public var text:String = "";
	public var redirect:Null<String> = "";

	public function new() {

	}

	public function toString() {
		return text + " => " + redirect;
	}
}

class ChoiceButton extends FlxSpriteGroup {
	public var idle:FlxSprite;
	public var sele:FlxSprite;
	public var text:FlxText;

	public var onSelected:Void->Void = null;
	public var redirectID:Int = 0;

	public function new(X:Float = 0, Y:Float = 0) {
		super(X, Y);

		idle = new FlxSprite(Paths.image("vn/options"));
		sele = new FlxSprite(Paths.image("vn/options_selected"));

		idle.antialiasing = true;
		sele.antialiasing = true;

		idle.scale.set(0.666, 0.666);
		sele.scale.set(0.666, 0.666);

		idle.updateHitbox();
		sele.updateHitbox();

		sele.alpha = 0.00001;

		moves = false;

		text = new FlxText(0, 0, FlxG.width, "PLACEHOLDER", 32);
		text.y = Math.abs(text.height / 2 - idle.height / 2);
		text.font = Paths.font("fnf.ttf");
		text.bold = true;
		text.antialiasing = true;
		text.alignment = CENTER;

		add(idle);
		add(sele);

		add(text);
	}

	public var selected(default, set):Bool = false;
	function set_selected(v:Bool) {
		idle.alpha = !v ? 1 : 0.00001;
		sele.alpha =  v ? 1 : 0.00001;
		return selected = v;
	}

	override function update(elapsed:Float) {
		if(!exists) return;
		if(!VisualNovel.allowInput) return;

		super.update(elapsed);

		if(FlxG.mouse.justMoved) {
			if(checkOverlap(idle, 30, 5)) {
				selected = true;
			} else {
				selected = false;
			}
		}

		if(FlxG.mouse.justPressed) {
			if(checkOverlap(idle, 30, 5)) {
				VisualNovel.allowInput = false;
				if(onSelected != null)
					onSelected();
			}
		}

		text.screenCenter(X);
		idle.screenCenter(X);
		sele.screenCenter(X);
	}

	function checkOverlap(group:FlxSprite, widthExtend:Float = 0, heightExtend:Float = 0) {
		var mouse = FlxG.mouse.getPosition();

		var rect = FlxRect.weak(group.x - widthExtend/2, group.y - heightExtend/2, group.width + widthExtend, group.height + heightExtend);
		var val = mouse.inRect(rect);

		rect.putWeak();
		mouse.put();

		return val;
	}
}