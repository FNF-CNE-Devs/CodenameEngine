package funkin.game;

import flixel.math.FlxPoint;
import funkin.backend.MusicBeatGroup;
import flixel.FlxState;
import haxe.xml.Access;
import funkin.backend.system.interfaces.IBeatReceiver;
import funkin.backend.scripting.Script;
import haxe.io.Path;

using StringTools;

class Stage extends FlxBasic implements IBeatReceiver {
	public var stageXML:Access;
	public var stagePath:String;
	public var stageSprites:Map<String, FlxSprite> = [];
	public var stageScript:Script;
	public var state:FlxState;
	public var characterPoses:Map<String, StageCharPos> = [];

	public function getSprite(name:String) {
		return stageSprites[name];
	}

	public function new(stage:String, ?state:FlxState) {
		super();

		if (state == null) state = PlayState.instance;
		if (state == null) state = FlxG.state;
		this.state = state;

		stagePath = Paths.xml('stages/$stage');
		try {
			if (Assets.exists(stagePath)) stageXML = new Access(Xml.parse(Assets.getText(stagePath)).firstElement());
		} catch(e) {
			Logs.trace('Couldn\'t load stage "$stage": ${e.message}', ERROR);
		}
		if (stageXML != null) {

			var spritesParentFolder = "";
			if (PlayState.instance != null) {
				if (stageXML.has.zoom) {
					var parsed:Null<Float> = Std.parseFloat(stageXML.att.zoom);
					if (parsed != null && PlayState.instance != null) PlayState.instance.defaultCamZoom = parsed;
				}
				PlayState.instance.curStage = stageXML.has.name ? stageXML.att.name : stage;
			}
			if (stageXML.has.folder) {
				spritesParentFolder = stageXML.att.folder;
				if (spritesParentFolder.charAt(spritesParentFolder.length-1) != "/") spritesParentFolder = spritesParentFolder + "/";
			}

			var elems = [];
			for(node in stageXML.elements) {
				if (node.name == "high-memory" && !Options.lowMemoryMode)
					for(e in node.elements)
						elems.push(e);
				else
					elems.push(node);
			}

			for(node in elems) {
				var sprite:Dynamic = switch(node.name) {
					case "sprite" | "spr" | "sparrow":
						if (!node.has.sprite || !node.has.name || !node.has.x || !node.has.y) continue;

						var spr = XMLUtil.createSpriteFromXML(node, spritesParentFolder, BEAT);

						if (!node.has.zoomfactor && PlayState.instance != null)
							spr.initialZoom = PlayState.instance.defaultCamZoom;

						stageSprites.set(spr.name, spr);
						state.add(spr);
						spr;
					case "box" | "solid":
						if ( !node.has.name || !node.has.width || !node.has.height) continue;

						var spr = new FlxSprite(
							(node.has.x) ? Std.parseFloat(node.att.x) : 0,
							(node.has.y) ? Std.parseFloat(node.att.y) : 0
						);

						(node.name == "solid" ? spr.makeSolid : spr.makeGraphic)(
							Std.parseInt(node.att.width),
							Std.parseInt(node.att.height),
							(node.has.color) ? CoolUtil.getColorFromDynamic(node.att.color) : -1
						);

						stageSprites.set(node.getAtt("name"), spr);
						state.add(spr);
						spr;
					case "boyfriend" | "bf" | "player":
						addCharPos("boyfriend", node, {
							x: 770,
							y: 100,
							scroll: 1,
							flip: true
						});
					case "girlfriend" | "gf":
						addCharPos("girlfriend", node, {
							x: 400,
							y: 130,
							scroll: 0.95,
							flip: false
						});
					case "dad" | "opponent":
						addCharPos("dad", node, {
							x: 100,
							y: 100,
							scroll: 1,
							flip: false
						});
					case "character":
						if (!node.has.name) continue;
						addCharPos(node.att.name, node);
					case "ratings" | "combo":
						if (PlayState.instance == null) continue;
						PlayState.instance.comboGroup.setPosition(
							Std.parseFloat(node.getAtt("x")).getDefault(PlayState.instance.comboGroup.x),
							Std.parseFloat(node.getAtt("y")).getDefault(PlayState.instance.comboGroup.y)
						);
						PlayState.instance.add(PlayState.instance.comboGroup);
						PlayState.instance.comboGroup;
					default: null;
				}
				if (sprite != null) {
					for(e in node.nodes.property)
						XMLUtil.applyXMLProperty(sprite, e);
				}
			}
		}

		if (characterPoses["girlfriend"] == null)
			addCharPos("girlfriend", null, {
				x: 400,
				y: 130,
				scroll: 0.95,
				flip: false
			});

		if (characterPoses["dad"] == null)
			addCharPos("dad", null, {
				x: 100,
				y: 100,
				scroll: 1,
				flip: false
			});

		if (characterPoses["boyfriend"] == null)
			addCharPos("boyfriend", null, {
				x: 770,
				y: 100,
				scroll: 1,
				flip: true
			});

		if (PlayState.instance == null) return;
		stageScript = Script.create(Paths.script('data/stages/$stage'));
		for(k=>e in stageSprites) {
			stageScript.set(k, e);
		}
		PlayState.instance.scripts.add(stageScript);
	}

	public function addCharPos(name:String, node:Access, ?nonXMLInfo:StageCharPosInfo):StageCharPos {
		var charPos = new StageCharPos();
		charPos.visible = charPos.active = false;

		if (nonXMLInfo != null) {
			charPos.setPosition(nonXMLInfo.x, nonXMLInfo.y);
			charPos.scrollFactor.set(nonXMLInfo.scroll, nonXMLInfo.scroll);
			charPos.flipX = nonXMLInfo.flip;
		}

		if (node != null) {
			charPos.x = Std.parseFloat(node.getAtt("x")).getDefault(charPos.x);
			charPos.y = Std.parseFloat(node.getAtt("y")).getDefault(charPos.y);
			charPos.camxoffset = Std.parseFloat(node.getAtt("camxoffset")).getDefault(charPos.camxoffset);
			charPos.camyoffset = Std.parseFloat(node.getAtt("camyoffset")).getDefault(charPos.camyoffset);
			charPos.skewX = Std.parseFloat(node.getAtt("skewx")).getDefault(charPos.skewX);
			charPos.skewY = Std.parseFloat(node.getAtt("skewy")).getDefault(charPos.skewY);
			charPos.flipX = (node.has.flip || node.has.flipX) ? (node.getAtt("flip") == "true" || node.getAtt("flipX") == "true") : charPos.flipX;

			var scale = Std.parseFloat(node.getAtt("scale")).getDefault(charPos.scale.x);
			charPos.scale.set(scale, scale);

			if (node.has.scroll) {
				var scroll:Null<Float> = Std.parseFloat(node.att.scroll);
				if (scroll != null) charPos.scrollFactor.set(scroll, scroll);
			} else {
				if (node.has.scrollx) {
					var scroll:Null<Float> = Std.parseFloat(node.att.scrollx);
					if (scroll != null) charPos.scrollFactor.x = scroll;
				}
				if (node.has.scrolly) {
					var scroll:Null<Float> = Std.parseFloat(node.att.scrolly);
					if (scroll != null) charPos.scrollFactor.y = scroll;
				}
			}
		}

		state.add(charPos);
		return characterPoses[name] = charPos;
	}

	public inline function isCharFlipped(posName:String, def:Bool = false)
		return characterPoses[posName] != null ? characterPoses[posName].flipX : def;

	public function applyCharStuff(char:Character, posName:String, id:Float = 0) {
		if (characterPoses[posName] == null)
			state.add(char);
		else {
			var charPos = characterPoses[posName];
			charPos.prepareCharacter(char, id);
			state.insert(state.members.indexOf(charPos), char);
		}
	}

	public function beatHit(curBeat:Int) {}

	public function stepHit(curStep:Int) {}

	public function measureHit(curMeasure:Int) {}
}

class StageCharPos extends FlxObject {
	public var charSpacingX:Float = 20;
	public var charSpacingY:Float = 0;
	public var camxoffset:Float = 0;
	public var camyoffset:Float = 0;
	public var skewX:Float = 0;
	public var skewY:Float = 0;
	public var flipX:Bool = false;
	public var scale:FlxPoint = FlxPoint.get(1, 1);

	public function new() {
		super();
		active = false;
		visible = false;
	}

	public override function destroy() {
		scale.put();
		super.destroy();
	}

	public function prepareCharacter(char:Character, id:Float = 0) {
		char.setPosition(x + (id * charSpacingX), y + (id * charSpacingY));
		char.scrollFactor.set(scrollFactor.x, scrollFactor.y);
		char.scale.x *= scale.x;
		char.scale.y *= scale.y;
	}
}
typedef StageCharPosInfo = {
	var x:Float;
	var y:Float;
	var flip:Bool;
	var scroll:Float;
}