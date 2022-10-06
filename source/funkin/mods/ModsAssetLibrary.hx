
// REDO THIS FOR FILE SUPPORT KINDA LIKE PSYCH BUT NOT MESSY

package funkin.mods;

import sys.FileStat;
import sys.FileSystem;
import openfl.utils.AssetLibrary;
import lime.utils.AssetManifest;

class ModsAssetLibrary extends AssetLibrary {
    private var editedTimes:Map<String, Float> = [];
    #if sys
    public override function __fromManifest(manifest:AssetManifest) {
        super.__fromManifest(manifest);

        var basePath = manifest.rootPath;
		if (basePath == null) basePath = "";
		if (basePath != "") basePath += "/";

        var stat:FileStat;
        for(asset in manifest.assets) {
            var id = asset.id;
            var assetPath = __cacheBreak(basePath + Reflect.field(asset, "path"));
            try {
                stat = FileSystem.stat(assetPath);
                if (stat != null) {
                    editedTimes.set(id, stat.mtime.getTime());
                }
            } catch(e) {
                trace(e);
            }
        }
    }
    #end

    public function getEditedTime(asset:String):Null<Float> {
        #if sys
        return editedTimes[asset];
        #else
        return null;
        #end
    }
}