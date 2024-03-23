package funkin.backend.assets;

import lime.utils.AssetLibrary;

#if sys
/**
 * Used to prevent crashes
 */
class ModdableAssetsFolder extends ModsFolderLibrary {
	public var oldLibrary:AssetLibrary;

	public override function exists(id:String, type:String) {
		if (!id.startsWith("assets/") && !exists('assets/$id', type))
			return oldLibrary.exists(id, type);
		return super.exists(id, type);
	}

	public override function getAsset(id:String, type:String):Dynamic {
		if (!id.startsWith("assets/")) {
			var possibleReplacement = getAsset('assets/$id', type);
			if (possibleReplacement != null)
				return possibleReplacement;
			return oldLibrary.getAsset(id, type);
		}
		return super.getAsset(id, type);
	}

	public function new(folder:String, libName:String, oldLib:AssetLibrary) {
		super(folder, libName);
		oldLibrary = oldLib;
		trace(Type.getClassName(Type.getClass(oldLibrary)));
	}

	private override function __parseAsset(asset:String):Bool {
		var prefix = 'assets/';
		if (!asset.startsWith(prefix)) return false;
		_parsedAsset = asset.substr(prefix.length);
		return true;
	}
}
#end