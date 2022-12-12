package flx3d;

import away3d.library.assets.Asset3DType;
import away3d.events.Asset3DEvent;
import away3d.loaders.parsers.OBJParser;
import away3d.utils.Cast;
import away3d.materials.TextureMaterial;
import haxe.io.Path;
import away3d.loaders.misc.AssetLoaderContext;
import openfl.Assets;
import away3d.entities.Mesh;
import away3d.loaders.Loader3D;

// FlxView3D with helpers for easier updating

class Flx3DView extends FlxView3D {
    public function initLoader() {
        if (_loader != null) return;
        _loader = new Loader3D();
        view.scene.addChild(_loader);
    }

	public function addMesh(assetPath:String, callback:Mesh->Void, ?texturePath:String) {
        initLoader();

        var model = Assets.getBytes(assetPath);
        if (model == null)
            throw 'Model at ${assetPath} was not found.';

        var context = new AssetLoaderContext();
        var noExt = Path.withoutExtension(assetPath);
        context.mapUrlToData('${Path.withoutDirectory(noExt)}.mtl', '$noExt.mtl');

        var material:TextureMaterial = null;
        if (texturePath != null)
            material = new TextureMaterial(Cast.bitmapTexture(texturePath));

        var token = _loader.loadData(model, context, null, new OBJParser());
        token.addEventListener(Asset3DEvent.MESH_COMPLETE, function(event) {
            if (event.type != Asset3DEvent.ASSET_COMPLETE) return;
            
            if (event.asset.assetType == Asset3DType.MESH) {
                var mesh = cast(event.asset, Mesh);
                if (material != null)
                    mesh.material = material;
                callback(mesh);
            }
        });
        return token;
	}
}