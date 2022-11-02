package funkin.system;

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
	 * Adds an XML animation to `sprite`.
	 * @param sprite Destination sprite
	 * @param anim Animation (Must be a `anim` XML node)
	 */
	public static function addXMLAnimation(sprite:FlxSprite, anim:Access):ErrorCode {
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
}