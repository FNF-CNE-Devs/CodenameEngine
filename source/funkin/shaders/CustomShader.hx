package funkin.shaders;

import haxe.Exception;
import openfl.display.ShaderParameter;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.Assets;
import hscript.IHScriptCustomBehaviour;

/**
 * Class for custom shaders.
 * 
 * To create one, create a `shaders` folder in your assets/mod folder, then add a file named `my-shader.frag` or/and `my-shader.vert`.
 * 
 * Non-existent shaders will only load the default one, and throw a warning in the console.
 * 
 * To access the shader's uniform variables, use `shader.variable`
 */
class CustomShader extends FunkinShader implements IHScriptCustomBehaviour {
    private static var __instanceFields = Type.getInstanceFields(CustomShader);
    /**
     * Creates a new custom shader
     * @param name Name of the frag and vert files.
     * @param glslVersion GLSL version to use. Defaults to `120`.
     */
    public function new(name:String, glslVersion:String = "120") {
        var fragShaderPath = Paths.fragShader(name);
        var vertShaderPath = Paths.vertShader(name);
        var fragCode = Assets.exists(fragShaderPath) ? Assets.getText(fragShaderPath) : null;
        var vertCode = Assets.exists(vertShaderPath) ? Assets.getText(vertShaderPath) : null;

        if (fragCode != null && vertCode != null) {
            // TODO: logging!!
        }
        
        super(fragCode, vertCode, glslVersion);
    }

    public function hget(v:String):Dynamic {
        if (__instanceFields.contains(v) || __instanceFields.contains('get_${v}')) {
            return Reflect.getProperty(this, v);
        }
        if (!Reflect.hasField(data, v)) return null;
        var field = Reflect.field(data, v);
        if (field is ShaderInput) {
            var si = cast(field, ShaderInput<Dynamic>);
            return si.input;
        } else if (field is ShaderParameter) {
            var sp = cast(field, ShaderParameter<Dynamic>);
            switch(sp.type) {
                case BOOL, FLOAT, INT:
                    return sp.value[0];
                default:
                    return sp.value;
            }
        }
        return field;
    }

    public function hset(v:String, val:Dynamic):Dynamic {
        if (__instanceFields.contains(v) || __instanceFields.contains('set_${v}')) {
            Reflect.setProperty(this, v, val);
            return val;
        }

        if (!Reflect.hasField(data, v)) {
            Reflect.setField(data, v, val);
            return val;
        } else {
            var field = Reflect.field(data, v);
            var cl = Std.string(Type.getClass(field));

            // cant do "field is ShaderInput" for some reason
            if (cl.startsWith("openfl.display.ShaderInput")) {
                // shader input!!
                if (!(val is BitmapData)) {
                    throw new ShaderTypeException(v, Type.getClass(val), BitmapData);
                    return null;
                }
                field.input = cast val;
            } else if (cl.startsWith("openfl.display.ShaderParameter")) {
                @:privateAccess
                if (field.__arrayLength <= 1) {
                    // that means we wait for a single number, instead of an array
                    @:privateAccess
                    if (field.__isInt && !(val is Int)) {
                        throw new ShaderTypeException(v, Type.getClass(val), 'Int');
                        return null;
                    } else 
                    @:privateAccess
                    if (field.__isBool && !(val is Bool)) {
                        throw new ShaderTypeException(v, Type.getClass(val), 'Bool');
                        return null;
                    } else 
                    @:privateAccess
                    if (field.__isFloat && !(val is Float)) {
                        throw new ShaderTypeException(v, Type.getClass(val), 'Float');
                        return null;
                    }
                    return field.value = [val];
                } else {
                    if (!(val is Array)) {
                        throw new ShaderTypeException(v, Type.getClass(val), Array);
                        return null;
                    }
                    return field.value = val;
                }
            }
        }

        return val;
    }
}

class ShaderTypeException extends Exception {
    var has:Class<Dynamic>;
    var want:Class<Dynamic>;
    var name:String;

    public function new(name:String, has:Class<Dynamic>, want:Dynamic) {
        this.has = has;
        this.want = want;
        this.name = name;
        super('ShaderTypeException - Tried to set the shader uniform "${name}" as a ${Type.getClassName(has)}, but the shader uniform is a ${Std.string(want)}.');
    }
}