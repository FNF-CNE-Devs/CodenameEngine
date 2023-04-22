package funkin.backend.utils;


/**
 * DOESNT SUPPORT CATEGORIES YET!!
 */
class IniUtil {
	public static inline function parseAsset(assetPath:String, ?defaultVariables:Map<String, String>)
		return parseString(Assets.getText(assetPath), defaultVariables);

	public static function parseString(data:String, ?defaultVariables:Map<String, String>) {
		var trimmed:String;
		var splitContent = [for(e in data.split("\n")) if ((trimmed = e.trim()) != "") trimmed];

		var finalMap:Map<String, String> = [];
		if (defaultVariables != null)
			for(k=>e in defaultVariables)
				finalMap[k] = e;

		for(line in splitContent) {
			// comment
			if (line.startsWith(";")) continue;
			// categories; not supported yet
			if (line.startsWith("[") && line.endsWith("]")) continue;

			var index = line.indexOf("=");
			var name = line.substr(0, index).trim();
			var value = line.substr(index+1).trim();

			if (value.startsWith("\"") && value.endsWith("\""))
				value = value.substr(1, value.length - 2);

			if (value.length == 0 || name.length == 0)
				continue;

			finalMap[name] = value;
		}
		return finalMap;
	}
}