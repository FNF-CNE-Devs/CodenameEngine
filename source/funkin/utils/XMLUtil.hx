package funkin.utils;

import funkin.system.FunkinSprite;
import funkin.system.ErrorCode;
import funkin.system.FunkinSprite.XMLAnimType;
import flixel.math.FlxMath;
import funkin.interfaces.IBeatReceiver;
import haxe.xml.Access;
import funkin.interfaces.IOffsetCompatible;
import flixel.FlxSprite;

using StringTools;
/**
 * Class made to make XML parsing easier.
 */
class XMLUtil {

    /**
     * Applies a property XML node to an object.
     * @param object Object to which the xml property will be applied
     * @param property `property` node.
     */
    public static function applyXMLProperty(object:Dynamic, property:Access):ErrorCode {
        if (!property.has.name || !property.has.type || !property.has.value) {
            Logs.trace('Failed to apply XML property: XML Element misses name, type, or value attributes.', WARNING);
            return MISSING_PROPERTY;
        }

        var value:Dynamic = switch(property.att.type.toLowerCase()) {
            case "float" | "number":            Std.parseFloat(property.att.value);
            case "int" | "integer" | "color":   Std.parseInt(property.att.value);
            case "string" | "str" | "text":     property.att.value;
            case "bool" | "boolean":            property.att.value.toLowerCase() == "true";
            default:                            return TYPE_INCORRECT;
        }
        if (value == null) return VALUE_NULL;

        try {
            Reflect.setProperty(object, property.att.name, value);
        } catch(e) {
            Logs.trace('Failed to apply XML property: $e on ${Type.getClass(object)}', WARNING);
            return REFLECT_ERROR;   
        }
        return OK;
    }

	/**
	 * Creates a new sprite based on a XML node.
	 */
	public static function createSpriteFromXML(node:Access, parentFolder:String = "", defaultAnimType:XMLAnimType = BEAT, ?cl:Class<FunkinSprite>):FunkinSprite {
		if (parentFolder == null) parentFolder = "";

		var spr:FunkinSprite = cl != null ? Type.createInstance(cl, []) : new FunkinSprite();
		spr.name = node.getAtt("name");
		spr.antialiasing = true;

		spr.loadAnimatedGraphic(Paths.image('$parentFolder${node.getAtt("sprite")}', null, true));

		spr.spriteAnimType = defaultAnimType;
		if (node.has.type)
			spr.spriteAnimType = XMLAnimType.fromString(node.att.type, spr.spriteAnimType);

		var x:Null<Float> = node.has.x ? Std.parseFloat(node.att.x) : null;
		var y:Null<Float> = node.has.y ? Std.parseFloat(node.att.y) : null;
		if (x != null) spr.x = x;
		if (y != null) spr.y = y;
		if (node.has.scroll) {
			var scroll:Null<Float> = Std.parseFloat(node.att.scroll);
			if (scroll != null) spr.scrollFactor.set(scroll, scroll);
		} else {
			if (node.has.scrollx) {
				var scroll:Null<Float> = Std.parseFloat(node.att.scrollx);
				if (scroll != null) spr.scrollFactor.x = scroll;
			} 
			if (node.has.scrolly) {
				var scroll:Null<Float> = Std.parseFloat(node.att.scrolly);
				if (scroll != null) spr.scrollFactor.y = scroll;
			} 
		}
		if (node.has.antialiasing) spr.antialiasing = node.att.antialiasing == "true";
		if (node.has.scale) {
			var scale:Null<Float> = Std.parseFloat(node.att.scale);
			if (scale != null) spr.scale.set(scale, scale);
		}
		if (node.has.updateHitbox && node.att.updateHitbox == "true") spr.updateHitbox();

		spr.zoomFactor = Std.parseFloat(node.getAtt("zoomfactor")).getDefault(spr.zoomFactor);
		
		for(anim in node.nodes.anim)
			addXMLAnimation(spr, anim);

		return spr;
	}

	public static function extractAnimFromXML(anim:Access, animType:XMLAnimType = NONE, loop:Bool = false):AnimData {
		var animData:AnimData = {
			name: null,
			anim: null,
			fps: 24,
			loop: loop,
			animType: animType,
			x: 0,
			y: 0,
			indices: []
		};

		if (anim.has.name) animData.name = anim.att.name;
		if (anim.has.type) animData.animType = XMLAnimType.fromString(anim.att.type, animData.animType);
		if (anim.has.anim) animData.anim = anim.att.anim;
		if (anim.has.fps) animData.fps = Std.parseInt(anim.att.fps);
		if (anim.has.x) animData.x = Std.parseFloat(anim.att.x);
		if (anim.has.y) animData.y = Std.parseFloat(anim.att.y);
		if (anim.has.loop) animData.loop = anim.att.loop == "true";
		if (anim.has.indices) {
			var indicesSplit = anim.att.indices.split(",");
			for(indice in indicesSplit) {
				var i = Std.parseInt(indice.trim());
				if (i != null)
					animData.indices.push(i);
			}
		} 

		return animData;
	}
	/**
	 * Adds an XML animation to `sprite`.
	 * @param sprite Destination sprite
	 * @param anim Animation (Must be a `anim` XML node)
	 */
	public static function addXMLAnimation(sprite:FlxSprite, anim:Access, loop:Bool = false):ErrorCode {
		var animType:XMLAnimType = NONE;
		if (sprite is FunkinSprite)
			animType = cast(sprite, FunkinSprite).spriteAnimType;

		return addAnimToSprite(sprite, extractAnimFromXML(anim, animType, loop));
	}

	public static function addAnimToSprite(sprite:FlxSprite, animData:AnimData):ErrorCode {
		if (animData.name != null && animData.anim != null) {
			if (animData.fps <= 0 #if web || animData.fps == null #end) animData.fps = 24;

			if (sprite is FunkinSprite && cast(sprite, FunkinSprite).animateAtlas != null) {
				var animateAnim = cast(sprite, FunkinSprite).animateAtlas.anim;
				if (animData.indices.length > 0)
					animateAnim.addBySymbolIndices(animData.name, animData.anim, animData.indices, animData.fps, animData.loop);
				else
					animateAnim.addBySymbol(animData.name, animData.anim, animData.fps, animData.loop);
			} else {
				if (animData.indices.length > 0)
					sprite.animation.addByIndices(animData.name, animData.anim, animData.indices, "", animData.fps, animData.loop);
				else
					sprite.animation.addByPrefix(animData.name, animData.anim, animData.fps, animData.loop);
			}

			if (sprite is IOffsetCompatible)
				cast(sprite, IOffsetCompatible).addOffset(animData.name, animData.x, animData.y);

			if (sprite is FunkinSprite) {
				var xmlSpr = cast(sprite, FunkinSprite);
				switch(animData.animType) {
					case BEAT:
						xmlSpr.beatAnims.push(animData.name);
					case LOOP:
						xmlSpr.animation.play(animData.name);
					default:
						// nothing
				}
			}
            return OK;
		}
        return MISSING_PROPERTY;
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
	var animType:XMLAnimType;
}