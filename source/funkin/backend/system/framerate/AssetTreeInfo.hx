package funkin.backend.system.framerate;

import funkin.backend.assets.ModsAssetLibrary;

class AssetTreeInfo extends FramerateCategory {
	public function new() {
		super("Asset Libraries Tree Info");
	}

	public override function __enterFrame(t:Int) {
		if (alpha <= 0.05) return;
		var text = 'Not initialized yet\n';
		if (Paths.assetsTree != null){
			text = "";
			for(e in Paths.assetsTree.libraries) {
				var l = e;
				if (l is openfl.utils.AssetLibrary) {
					var al = cast(l, openfl.utils.AssetLibrary);
					@:privateAccess
					if (al.__proxy != null) l = al.__proxy;
				}

				if (l is ModsAssetLibrary)
					text += '${Type.getClassName(Type.getClass(l))} - ${cast(l, ModsAssetLibrary).libName} (${cast(l, ModsAssetLibrary).prefix})\n';
				else
					text += Std.string(e) + "\n";
			}
		}
		if (text != "")
			text = text.substr(0, text.length-1);

		this.text.text = text;
		super.__enterFrame(t);
	}
}