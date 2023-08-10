package funkin.backend.shaders;

import haxe.Exception;
import hscript.IHScriptCustomBehaviour;
import flixel.graphics.tile.FlxGraphicsShader;
import openfl.display3D.Program3D;
import flixel.system.FlxAssets.FlxShader;

import openfl.display.BitmapData;
import openfl.display.ShaderParameter;
import openfl.display.ShaderParameterType;
import openfl.display.ShaderInput;
import lime.utils.Float32Array;

using StringTools;

import openfl.display.ShaderParameter;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;

@:access(openfl.display3D.Context3D)
@:access(openfl.display3D.Program3D)
@:access(openfl.display.ShaderInput)
@:access(openfl.display.ShaderParameter)
class FunkinShader extends FlxShader implements IHScriptCustomBehaviour {
	private static var __instanceFields = Type.getInstanceFields(FunkinShader);

	public var glslVer:String = "120";

	/**
	 * Creates a new shader from the specified fragment and vertex source.
	 * Accepts `#pragma header`.
	 * @param frag Fragment source (pass `null` to use default)
	 * @param vert Vertex source (pass `null` to use default)
	 * @param glslVer Version of GLSL to use (defaults to 120)
	 */
	public override function new(frag:String, vert:String, glslVer:String = "120") {
		if (frag == null) frag = ShaderTemplates.defaultFragmentSource;
		if (vert == null) vert = ShaderTemplates.defaultVertexSource;
		this.glFragmentSource = frag;
		this.glVertexSource = vert;

		this.glslVer = glslVer;
		super();
	}

	@:noCompletion override private function set_glFragmentSource(value:String):String
	{
		if(value == null)
			value = ShaderTemplates.defaultFragmentSource;
		value = value.replace("#pragma header", ShaderTemplates.fragHeader).replace("#pragma body", ShaderTemplates.fragBody);
		if (value != __glFragmentSource)
		{
			__glSourceDirty = true;
		}

		return __glFragmentSource = value;
	}

	@:noCompletion override private function set_glVertexSource(value:String):String
	{
		if(value == null)
			value = ShaderTemplates.defaultVertexSource;
		value = value.replace("#pragma header", ShaderTemplates.vertHeader).replace("#pragma body", ShaderTemplates.vertBody);
		if (value != __glVertexSource)
		{
			__glSourceDirty = true;
		}

		return __glVertexSource = value;
	}

	@:noCompletion private override function __initGL():Void
	{
		if (__glSourceDirty || __paramBool == null)
		{
			__glSourceDirty = false;
			program = null;

			__inputBitmapData = new Array();
			__paramBool = new Array();
			__paramFloat = new Array();
			__paramInt = new Array();

			__processGLData(glVertexSource, "attribute");
			__processGLData(glVertexSource, "uniform");
			__processGLData(glFragmentSource, "uniform");
		}

		if (__context != null && program == null)
		{
			var prefix = '#version ${glslVer}\n';

			var gl = __context.gl;

			prefix += "#ifdef GL_ES
				"
				+ (precisionHint == FULL ? "#ifdef GL_FRAGMENT_PRECISION_HIGH
				precision highp float;
				#else
				precision mediump float;
				#endif" : "precision lowp float;")
				+ "
				#endif
				";

			var vertex = prefix + glVertexSource;
			var fragment = prefix + glFragmentSource;

			var id = vertex + fragment;

			if (__context.__programs.exists(id))
			{
				program = __context.__programs.get(id);
			}
			else
			{
				program = __context.createProgram(GLSL);

				program.__glProgram = __createGLProgram(vertex, fragment);

				__context.__programs.set(id, program);
			}

			if (program != null)
			{
				glProgram = program.__glProgram;

				for (input in __inputBitmapData)
				{

					if (input.__isUniform)
					{
						input.index = gl.getUniformLocation(glProgram, input.name);
					}
					else
					{
						input.index = gl.getAttribLocation(glProgram, input.name);
					}
				}

				for (parameter in __paramBool)
				{

					if (parameter.__isUniform)
					{
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}

				for (parameter in __paramFloat)
				{

					if (parameter.__isUniform)
					{
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}

				for (parameter in __paramInt)
				{

					if (parameter.__isUniform)
					{

						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{

						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}
			}
			// initInstance(vertex, fragment); // btw make sure to disable the prefixes for ._isInstance
		}
	}

	@:noCompletion private override function __processGLData(source:String, storageType:String):Void
	{
		var lastMatch = 0, position, regex, name, type;

		if (storageType == "uniform")
		{
			regex = ~/uniform ([A-Za-z0-9]+) ([A-Za-z0-9_]+)/;
		}
		else
		{
			regex = ~/attribute ([A-Za-z0-9]+) ([A-Za-z0-9_]+)/;
		}

		while (regex.matchSub(source, lastMatch))
		{
			type = regex.matched(1);
			name = regex.matched(2);

			if (StringTools.startsWith(name, "gl_"))
			{
				continue;
			}

			var isUniform = (storageType == "uniform");

			if (StringTools.startsWith(type, "sampler"))
			{
				var input = new ShaderInput<BitmapData>();
				input.name = name;
				@:privateAccess
				input.__isUniform = isUniform;
				__inputBitmapData.push(input);

				switch (name)
				{
					case "openfl_Texture":
						__texture = input;
					case "bitmap":
						__bitmap = input;
					default:
				}

				Reflect.setField(__data, name, input);
				try{Reflect.setField(this, name, input);} catch(e) {}
			}
			else if (!Reflect.hasField(__data, name) || Reflect.field(__data, name) == null)
			{
				var parameterType:ShaderParameterType = switch (type)
				{
					case "bool": BOOL;
					case "double", "float": FLOAT;
					case "int", "uint": INT;
					case "bvec2": BOOL2;
					case "bvec3": BOOL3;
					case "bvec4": BOOL4;
					case "ivec2", "uvec2": INT2;
					case "ivec3", "uvec3": INT3;
					case "ivec4", "uvec4": INT4;
					case "vec2", "dvec2": FLOAT2;
					case "vec3", "dvec3": FLOAT3;
					case "vec4", "dvec4": FLOAT4;
					case "mat2", "mat2x2": MATRIX2X2;
					case "mat2x3": MATRIX2X3;
					case "mat2x4": MATRIX2X4;
					case "mat3x2": MATRIX3X2;
					case "mat3", "mat3x3": MATRIX3X3;
					case "mat3x4": MATRIX3X4;
					case "mat4x2": MATRIX4X2;
					case "mat4x3": MATRIX4X3;
					case "mat4", "mat4x4": MATRIX4X4;
					default: null;
				}

				var length = switch (parameterType)
				{
					case BOOL2, INT2, FLOAT2: 2;
					case BOOL3, INT3, FLOAT3: 3;
					case BOOL4, INT4, FLOAT4, MATRIX2X2: 4;
					case MATRIX3X3: 9;
					case MATRIX4X4: 16;
					default: 1;
				}

				var arrayLength = switch (parameterType)
				{
					case MATRIX2X2: 2;
					case MATRIX3X3: 3;
					case MATRIX4X4: 4;
					default: 1;
				}

				switch (parameterType)
				{
					case BOOL, BOOL2, BOOL3, BOOL4:
						var parameter = new ShaderParameter<Bool>();
						parameter.name = name;
						@:privateAccess
						parameter.type = parameterType;
						@:privateAccess
						parameter.__arrayLength = arrayLength;
						@:privateAccess
						parameter.__isBool = true;
						@:privateAccess
						parameter.__isUniform = isUniform;
						@:privateAccess
						parameter.__length = length;
						__paramBool.push(parameter);

						if (name == "openfl_HasColorTransform")
						{
							__hasColorTransform = parameter;
						}

						Reflect.setField(__data, name, parameter);
						try{Reflect.setField(this, name, parameter);} catch(e) {}

					case INT, INT2, INT3, INT4:
						var parameter = new ShaderParameter<Int>();
						parameter.name = name;
						@:privateAccess
						parameter.type = parameterType;
						@:privateAccess
						parameter.__arrayLength = arrayLength;
						@:privateAccess
						parameter.__isInt = true;
						@:privateAccess
						parameter.__isUniform = isUniform;
						@:privateAccess
						parameter.__length = length;
						@:privateAccess
						__paramInt.push(parameter);
						Reflect.setField(__data, name, parameter);
						try{Reflect.setField(this, name, parameter);} catch(e) {}

					default:
						var parameter = new ShaderParameter<Float>();
						parameter.name = name;
						@:privateAccess
						parameter.type = parameterType;
						@:privateAccess
						parameter.__arrayLength = arrayLength;
						#if lime
						@:privateAccess
						if (arrayLength > 0) parameter.__uniformMatrix = new Float32Array(arrayLength * arrayLength);
						#end
						@:privateAccess
						parameter.__isFloat = true;
						@:privateAccess
						parameter.__isUniform = isUniform;
						@:privateAccess
						parameter.__length = length;
						__paramFloat.push(parameter);

						if (StringTools.startsWith(name, "openfl_"))
						{
							switch (name)
							{
								case "openfl_Alpha": __alpha = parameter;
								case "openfl_ColorMultiplier": __colorMultiplier = parameter;
								case "openfl_ColorOffset": __colorOffset = parameter;
								case "openfl_Matrix": __matrix = parameter;
								case "openfl_Position": __position = parameter;
								case "openfl_TextureCoord": __textureCoord = parameter;
								case "openfl_TextureSize": __textureSize = parameter;
								default:
							}
						}

						Reflect.setField(__data, name, parameter);
						try{Reflect.setField(this, name, parameter);} catch(e) {}
				}
			}

			position = regex.matchedPos();
			lastMatch = position.pos + position.len;
		}
	}

	public function hget(name:String):Dynamic {
		if (__instanceFields.contains(name) || __instanceFields.contains('get_${name}')) {
			return Reflect.getProperty(this, name);
		}
		if (!Reflect.hasField(data, name)) return null;
		var field = Reflect.field(data, name);
		var cl = Type.getClassName(Type.getClass(field));

		// cant do "field is ShaderInput" for some reason
		if (cl.startsWith("openfl.display.ShaderParameter")) {
			var sp = cast(field, ShaderParameter<Dynamic>);
			@:privateAccess
			return (sp.__length > 1) ? sp.value : sp.value[0];
		} else if (cl.startsWith("openfl.display.ShaderInput")) {
			var si = cast(field, ShaderInput<Dynamic>);
			return si.input;
		}
		return field;
	}

	public function hset(name:String, val:Dynamic):Dynamic {
		if (__instanceFields.contains(name) || __instanceFields.contains('set_${name}')) {
			Reflect.setProperty(this, name, val);
			return val;
		}

		if (!Reflect.hasField(data, name)) {
			Reflect.setField(data, name, val);
			return val;
		} else {
			var field = Reflect.field(data, name);
			var cl = Type.getClassName(Type.getClass(field));
			// cant do "field is ShaderInput" for some reason
			if (cl.startsWith("openfl.display.ShaderParameter")) {
				@:privateAccess
				if (field.__length <= 1) {
					// that means we wait for a single number, instead of an array
					@:privateAccess
					if (field.__isInt && !(val is Int)) {
						throw new ShaderTypeException(name, Type.getClass(val), 'Int');
						return null;
					} else
					@:privateAccess
					if (field.__isBool && !(val is Bool)) {
						throw new ShaderTypeException(name, Type.getClass(val), 'Bool');
						return null;
					} else
					@:privateAccess
					if (field.__isFloat && !(val is Float)) {
						throw new ShaderTypeException(name, Type.getClass(val), 'Float');
						return null;
					}
					return field.value = [val];
				} else {
					if (!(val is Array)) {
						throw new ShaderTypeException(name, Type.getClass(val), Array);
						return null;
					}
					return field.value = val;
				}
			} else if (cl.startsWith("openfl.display.ShaderInput")) {
				// shader input!!
				if (!(val is BitmapData)) {
					throw new ShaderTypeException(name, Type.getClass(val), BitmapData);
					return null;
				}
				field.input = cast val;
			}
		}

		return val;
	}
}

class ShaderTemplates {
	public static final fragHeader:String = "varying float openfl_Alphav;
varying vec4 openfl_ColorMultiplierv;
varying vec4 openfl_ColorOffsetv;
varying vec2 openfl_TextureCoordv;

uniform bool openfl_HasColorTransform;
uniform vec2 openfl_TextureSize;
uniform sampler2D bitmap;

uniform bool hasTransform;
uniform bool hasColorTransform;

vec4 flixel_texture2D(sampler2D bitmap, vec2 coord)
{
	vec4 color = texture2D(bitmap, coord);
	if (!hasTransform)
	{
		return color;
	}

	if (color.a == 0.0)
	{
		return vec4(0.0, 0.0, 0.0, 0.0);
	}

	if (!hasColorTransform)
	{
		return color * openfl_Alphav;
	}

	color = vec4(color.rgb / color.a, color.a);

	mat4 colorMultiplier = mat4(0);
	colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
	colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
	colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
	colorMultiplier[3][3] = openfl_ColorMultiplierv.w;

	color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);

	if (color.a > 0.0)
	{
		return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
	}
	return vec4(0.0, 0.0, 0.0, 0.0);
}

uniform vec4 _camSize;

float map(float value, float min1, float max1, float min2, float max2) {
	return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

vec2 getCamPos(vec2 pos) {
	vec4 size = _camSize / vec4(openfl_TextureSize, openfl_TextureSize);
	return vec2(map(pos.x, size.x, size.x + size.z, 0.0, 1.0), map(pos.y, size.y, size.y + size.w, 0.0, 1.0));
}
vec2 camToOg(vec2 pos) {
	vec4 size = _camSize / vec4(openfl_TextureSize, openfl_TextureSize);
	return vec2(map(pos.x, 0.0, 1.0, size.x, size.x + size.z), map(pos.y, 0.0, 1.0, size.y, size.y + size.w));
}
vec4 textureCam(sampler2D bitmap, vec2 pos) {
	return flixel_texture2D(bitmap, camToOg(pos));
}";

	public static final fragBody:String = "vec4 color = texture2D (bitmap, openfl_TextureCoordv);

if (color.a == 0.0) {

	gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);

} else if (openfl_HasColorTransform) {

	color = vec4 (color.rgb / color.a, color.a);

	mat4 colorMultiplier = mat4 (0);
	colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
	colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
	colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
	colorMultiplier[3][3] = 1.0; // openfl_ColorMultiplierv.w;

	color = clamp (openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);

	if (color.a > 0.0) {

		gl_FragColor = vec4 (color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);

	} else {

		gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);

	}

} else {

	gl_FragColor = color * openfl_Alphav;

}";
	public static final vertHeader:String = "attribute float openfl_Alpha;
attribute vec4 openfl_ColorMultiplier;
attribute vec4 openfl_ColorOffset;
attribute vec4 openfl_Position;
attribute vec2 openfl_TextureCoord;

varying float openfl_Alphav;
varying vec4 openfl_ColorMultiplierv;
varying vec4 openfl_ColorOffsetv;
varying vec2 openfl_TextureCoordv;

uniform mat4 openfl_Matrix;
uniform bool openfl_HasColorTransform;
uniform vec2 openfl_TextureSize;";

	public static final vertBody:String = "openfl_Alphav = openfl_Alpha;
openfl_TextureCoordv = openfl_TextureCoord;

if (openfl_HasColorTransform) {

	openfl_ColorMultiplierv = openfl_ColorMultiplier;
	openfl_ColorOffsetv = openfl_ColorOffset / 255.0;

}

gl_Position = openfl_Matrix * openfl_Position;";


	public static final defaultVertexSource:String = "#pragma header

attribute float alpha;
attribute vec4 colorMultiplier;
attribute vec4 colorOffset;
uniform bool hasColorTransform;

void main(void)
{
	#pragma body

	openfl_Alphav = openfl_Alpha * alpha;

	if (hasColorTransform)
	{
		openfl_ColorOffsetv = colorOffset / 255.0;
		openfl_ColorMultiplierv = colorMultiplier;
	}
}";


	// TODO: camera stuff
	public static final defaultFragmentSource:String = "#pragma header

void main(void)
{
	gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
}";
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