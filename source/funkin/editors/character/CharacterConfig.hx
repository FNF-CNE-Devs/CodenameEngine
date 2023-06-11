package funkin.editors.character;

import haxe.xml.Printer;
import sys.io.File;
import sys.FileSystem;
import flixel.group.FlxGroup;
import haxe.xml.Access;
import haxe.Exception;
import flixel.util.FlxColor;
import funkin.game.Character.CharacterData;

class CharacterConfig extends FlxTypedGroup<FlxBasic>
{
	public static var DEFAULT_CHARACTER = "bf";

	public static function loadCharacterData(character:String):CharacterData
	{
		var xml:Access;

		var charData:CharacterData = {
			offsetY: 0,
			offsetX: 0,
			camOffsetY: 0,
			camOffsetX: 0,
			quickDancer: false,
			icon: character,
			iconColor: FlxColor.fromRGB(94, 94, 94),
			scale: 1,
			isPlayer: false,
			isGF: false,
			holdTime: 4,
			flipX: false,
			antialiasing: true,
			sprite: "bf",
			name: character,
			animations: []
		}

		var xmlPath = Paths.xml('characters/$character');

		var plainXML = Assets.getText(xmlPath);
		try
		{
			var charXML = Xml.parse(plainXML).firstElement();
			if (charXML == null)
				throw new Exception("Missing \"character\" node in XML.");
			xml = new Access(charXML);
		}

		charData = xmlToData(charData, xml);

		return charData;
	}

	public static function xmlToData(charData:CharacterData, xml:Access):CharacterData
	{
		if (xml.has.isPlayer)
			charData.isPlayer = (xml.att.isPlayer == "true");
		if (xml.has.isGF)
			charData.isGF = (xml.att.isGF == "true");
		if (xml.has.x)
			charData.offsetX = Std.parseFloat(xml.att.x);
		if (xml.has.y)
			charData.offsetY = Std.parseFloat(xml.att.y);
		if (xml.has.gameOverChar)
			charData.gameOverChar = xml.att.gameOverChar;
		if (xml.has.camx)
			charData.camOffsetX = Std.parseFloat(xml.att.camx);
		if (xml.has.camy)
			charData.camOffsetY = Std.parseFloat(xml.att.camy);
		if (xml.has.holdTime)
			charData.holdTime = CoolUtil.getDefault(Std.parseFloat(xml.att.holdTime), 4);
		if (xml.has.flipX)
			charData.flipX = (xml.att.flipX == "true");
		if (xml.has.icon)
			charData.icon = xml.att.icon;
		if (xml.has.iconColor)
				charData.iconColor = stringToRGB(xml.att.iconColor);
		if (xml.has.scale)
		{
			var scale = Std.parseFloat(xml.att.scale).getDefault(1);
			charData.scale = scale;
		}
		if (xml.has.antialiasing)
			charData.antialiasing = (xml.att.antialiasing == "true");
		if (xml.has.sprite)
			charData.sprite = xml.att.sprite;
		else
			charData.sprite = charData.name;

		for (anim in xml.nodes.anim)
		{
			var animType:XMLAnimType = NONE;
			var animloop = false;
			if (anim.has.loop)
				animloop = (anim.att.loop == "true");
			charData.animations.push(XMLUtil.extractAnimFromXML(anim, animType, animloop));
		}
		return charData;
	}

	public static function dataToXml(charData:CharacterData):Access
	{
		var root = Xml.createElement("character");
		root.set("x", Std.string(Math.floor(charData.offsetX)));
		root.set("y", Std.string(Math.floor(charData.offsetY)));
		root.set("gameOverChar", Std.string(charData.gameOverChar));
		root.set("camx", Std.string(Math.floor(charData.camOffsetX)));
		root.set("camy", Std.string(Math.floor(charData.camOffsetY)));
		root.set("holdTime", Std.string(charData.holdTime));
		root.set("flipX", Std.string(charData.flipX));
		root.set("icon", charData.icon);
		root.set("iconColor", Std.string(charData.iconColor));
		root.set("scale", Std.string(charData.scale));
		root.set("antialiasing", Std.string(charData.antialiasing));
		root.set("sprite", Std.string(charData.sprite));
		root.set("isPlayer", Std.string(charData.isPlayer));
		root.set("isGF", Std.string(charData.isGF));

		for (anim in charData.animations)
		{
			var child:Xml = Xml.createElement('anim');
			child.set("name", Std.string(anim.name));
			child.set("anim", Std.string(anim.anim));
			child.set("loop", Std.string(anim.loop));
			child.set("fps", Std.string(anim.fps));
			child.set("x", Std.string(anim.x));
			child.set("y", Std.string(anim.y));
			child.set("indices", Std.string(anim.indices));
			root.addChild(child);
		}
		var xml = new Access(Xml.parse('${root.toString()}'));

		return xml;
	}

	public static function stringToRGB(rgbColor:String):FlxColor
	{
		var colorSplit = rgbColor.split(",");
			if (colorSplit[0] != null && colorSplit[1] != null && colorSplit[2] != null)
				return FlxColor.fromRGB(Std.parseInt(colorSplit[0]), Std.parseInt(colorSplit[1]), Std.parseInt(colorSplit[2]));
			else
				return FlxColor.fromRGB(90,90,90);
	}

	public static function rgbToString(color:FlxColor):String
		return '${color.red}, ${color.green}, ${color.blue}';
	/**
	 * @return Saves the character to the specific song folder path.
	 */
	public static function save(character:String, xml:String):String
	{
		var charPath = '';
		var data = '$xml';
		#if sys
		var charPath = '${character}';

		File.saveContent(charPath, data);

		// idk how null reacts to it so better be sure
		#end
		return xml;
	}

	public static function generateCharXML(xml:Xml):String
	{
		return '<!DOCTYPE codename-engine-character>\n${Printer.print(xml, true)}';
	}
}
