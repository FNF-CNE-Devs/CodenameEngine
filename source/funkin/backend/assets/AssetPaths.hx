// UNUSED

package funkin.backend.assets;

/**
 * {
		"characterXML": "data/characters/{0}.xml",
		"characterScript": "data/characters/{0}",
		"config": "data/config/",
		"dialogueBoxes": "data/dialogue/boxes/",
		"dialogueCharacters": "data/dialogue/characters/",
		"globalChartScripts": "data/charts/",
		"splashData": "data/splashes/{0}.xml",
		"stageXML": "data/stages/{0}.xml",
		"stageScript": "data/stages/{0}",
		"titleIntroText": "data/titlescreen/introText.txt",
		"weekList": "data/weeks/weeks.txt",
		"weekData": "data/weeks/weeks/{0}.xml",
		"weekCharacterData": "data/weeks/characters/{0}.xml",
		"noteTypeScript": "data/notes/{0}",
		"stateScript": "data/states/{0}",
		"globalScript": "data/global",

		"txt": "data/{0}.txt",
		"ini": "data/{0}.ini",
		"fragShader": "shaders/{0}.frag",
		"vertShader": "shaders/{0}.vert",
		"xml": "data/{0}.xml",
		"json": "data/{0}.json",
		"ps1": "data/{0}.ps1",
		"sound": "sounds/{0}.{1}",
		"music": "music/{0}.{1}",
		"image": "images/{0}",

		"instDefault": "songs/{0}/song/Inst.{1}",
		"instDifficulty": "songs/{0}/song/Inst-{1}.{2}",
		"voicesDefault": "songs/{0}/song/Voices.{1}",
		"voicesDifficulty": "songs/{0}/song/Voices-{1}.{2}"
	}
 */
/**
	Static class containing all of the paths for every different feature of the engine.
**/
@:final
class AssetPaths {
	/**¨
		Path to the data folder. Used by Paths functions.
	**/
	public static final data:AssetString = "assets/data/";
	public static final characters:AssetString = "assets/data/characters/";
	public static final config:AssetString = "assets/data/config/";
	public static final dialogueBoxes:AssetString = "assets/data/dialogue/boxes/";
	public static final dialogueCharacters:AssetString = "assets/data/dialogue/characters/";
	public static final globalChartScripts:AssetString = "assets/data/charts/";
	public static final splashes:AssetString = "assets/data/splashes/";
	public static final stages:AssetString = "assets/data/stages/";
	public static final titleIntroText:AssetString = "assets/data/titlescreen/introText.txt";
	public static final weeksData:AssetString = "assets/data/weeks/weeks.txt";
}

abstract AssetString(String) from String to String {
	public inline function format(values:Array<String>) {
		var str = this;
		var i = 0;
		while(str.contains('{$i}')) {
			str = str.replace('{$i}', values[i]);
			i++;
		}
		return str;
	}
}