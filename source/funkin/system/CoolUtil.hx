package funkin.system;

import funkin.interfaces.IOffsetCompatible;
import lime.utils.Assets;
import flixel.animation.FlxAnimation;
import haxe.xml.Access;
import flixel.FlxSprite;

using StringTools;

class CoolUtil
{
	public static function addXMLAnimation(sprite:FlxSprite, anim:Access) {
		var animData:AnimData = {
			name: null,
			anim: null,
			fps: 24,
			loop: false,
			x: 0,
			y: 0,
			indices: []
		};

		if (anim.has.name) animData.name = anim.att.name;
		if (anim.has.anim) animData.anim = anim.att.anim;
		if (anim.has.fps) animData.fps = Std.parseInt(anim.att.fps);
		if (anim.has.x) animData.x = Std.parseFloat(anim.att.x);
		if (anim.has.y) animData.y = Std.parseFloat(anim.att.y);
		if (anim.has.indices) {
			var indicesSplit = anim.att.indices.split(",");
			for(indice in indicesSplit) {
				var i = Std.parseInt(indice.trim());
				if (i != null)
					animData.indices.push(i);
			}
		} 

		if (animData.name != null && animData.anim != null) {
			if (animData.fps <= 0 #if web || animData.fps == null #end) animData.fps = 24;

			if (animData.indices.length > 0)
				sprite.animation.addByIndices(animData.name, animData.anim, animData.indices, "", animData.fps, animData.loop);
			else
				sprite.animation.addByPrefix(animData.name, animData.anim, animData.fps, animData.loop);

			if (sprite is IOffsetCompatible)
				cast(sprite, IOffsetCompatible).addOffset(animData.name, animData.x, animData.y);
		}
	}
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		return [for(e in Assets.getText(path).trim().split('\n')) e.trim()];
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		return [for (i in min...max) i];
	}

	public static function switchAnimFrames(anim1:FlxAnimation, anim2:FlxAnimation) {
		if (anim1 == null || anim2 == null) return;
		var old = anim1.frames;
		anim1.frames = anim2.frames;
		anim2.frames = old;
	}
}

typedef AnimData = {
	var name:String;
	var anim:String;
	var fps:Int;
	var loop:Bool;
	var x:Float;
	var y:Float;
	var indices:Array<Int>;
}