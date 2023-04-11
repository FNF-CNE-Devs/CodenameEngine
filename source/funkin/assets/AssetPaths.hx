package funkin.assets;

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