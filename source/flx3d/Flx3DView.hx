package flx3d;

import flixel.FlxG;
import flx3d.Flx3DUtil;
import away3d.library.assets.Asset3DType;
import away3d.events.Asset3DEvent;
import away3d.loaders.parsers.*;
import away3d.utils.Cast;
import away3d.materials.TextureMaterial;
import haxe.io.Path;
import away3d.loaders.misc.AssetLoaderContext;
import openfl.Assets;
import away3d.entities.Mesh;
import away3d.loaders.Loader3D;

// FlxView3D with helpers for easier updating

class Flx3DView extends FlxView3D {
    public var _loader:Loader3D;

    public function new(x:Float = 0, y:Float = 0, width:Int = -1, height:Int = -1) {
        if (!Flx3DUtil.is3DAvailable())
            throw "[Flx3DView] 3D is not available on this platform. Stages in use: " + Flx3DUtil.getTotal3D() + ", Max stages allowed: " + FlxG.stage.stage3Ds.length + ".";
        super(x, y, width, height);
    }

    public function initLoader() {
        if (_loader != null) return;
        _loader = new Loader3D();
        _loader.addEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetComplete);
        view.scene.addChild(_loader);
    }

    private var meshCallback:Mesh->Void = null;

    private var queue:Array<MeshQueueItem> = [];

    private function onAssetComplete(event:Asset3DEvent) {
        if (event.asset != null && event.asset.assetType == Asset3DType.MESH) {
            var mesh:Mesh = cast(event.asset, Mesh);
            if (meshCallback != null)
                meshCallback(mesh);
            meshCallback = null;
            if (queue.length > 0) {
                var m = queue.shift();
                addMesh(m.assetPath, m.callback, m.texturePath);
            }
        }
    }

	public function addMesh(assetPath:String, callback:Mesh->Void, ?texturePath:String, smoothTexture:Bool = true) {
        initLoader();

        var model = Assets.getBytes(assetPath);
        if (model == null)
            throw 'Model at ${assetPath} was not found.';
        if (meshCallback != null) {
            queue.push({
                assetPath: assetPath,
                callback: callback,
                texturePath: texturePath
            });
            return null;
        }

        var context = new AssetLoaderContext();
        var noExt = Path.withoutExtension(assetPath);
        trace(noExt);
        context.mapUrlToData('${Path.withoutDirectory(noExt)}.mtl', '$noExt.mtl');

        var material:TextureMaterial = null;
        if (texturePath != null)
            material = new TextureMaterial(Cast.bitmapTexture(texturePath), smoothTexture);

        var token = _loader.loadData(model, context, null, switch(Path.extension(assetPath).toLowerCase()) {
            case "dae": new DAEParser();
            case "md2": new MD2Parser();
            case "md5": new MD5MeshParser();
            case "awd": new AWDParser();
            default:    new OBJParser();
        });
        meshCallback = function(mesh) {
            if (material != null)
                mesh.material = material;
            callback(mesh);
        };
        return token;
	}
}

typedef MeshQueueItem = {
    var assetPath:String;
    var callback:Mesh->Void;
    var texturePath:String;
}