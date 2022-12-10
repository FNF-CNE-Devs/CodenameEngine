package funkin.shaders;

import haxe.Exception;
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
class CustomShader extends FunkinShader
{
	/**
	 * Creates a new custom shader
	 * @param name Name of the frag and vert files.
	 * @param glslVersion GLSL version to use. Defaults to `120`.
	 */
	public function new(name:String, glslVersion:String = "120")
	{
		var fragShaderPath = Paths.fragShader(name);
		var vertShaderPath = Paths.vertShader(name);
		var fragCode = Assets.exists(fragShaderPath) ? Assets.getText(fragShaderPath) : null;
		var vertCode = Assets.exists(vertShaderPath) ? Assets.getText(vertShaderPath) : null;

		if (fragCode != null && vertCode != null)
		{
			// TODO: logging!!
		}

		super(fragCode, vertCode, glslVersion);
	}
}
