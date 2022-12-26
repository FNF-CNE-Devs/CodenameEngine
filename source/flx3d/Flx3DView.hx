package flx3d;

import away3d.library.Asset3DLibraryBundle;
import away3d.events.LoaderEvent;
import away3d.loaders.AssetLoader;
import away3d.loaders.misc.AssetLoaderToken;
import funkin.system.Logs;
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
import funkin.windows.WindowsAPI.ConsoleColor;

// FlxView3D with helpers for easier updating

class Flx3DView extends FlxView3D {

    public function new(x:Float = 0, y:Float = 0, width:Int = -1, height:Int = -1) {
        if (!Flx3DUtil.is3DAvailable())
            throw "[Flx3DView] 3D is not available on this platform. Stages in use: " + Flx3DUtil.getTotal3D() + ", Max stages allowed: " + FlxG.stage.stage3Ds.length + ".";
        super(x, y, width, height);
    }

	public function addModel(assetPath:String, callback:Asset3DEvent->Void, ?texturePath:String, smoothTexture:Bool = true) {

        var model = Assets.getBytes(assetPath);
        if (model == null)
            throw 'Model at ${assetPath} was not found.';
        
        var context = new AssetLoaderContext();
        var noExt = Path.withoutExtension(assetPath);
        trace(noExt);
        context.mapUrlToData('${Path.withoutDirectory(noExt)}.mtl', '$noExt.mtl');

        var material:TextureMaterial = null;
        if (texturePath != null)
            material = new TextureMaterial(Cast.bitmapTexture(texturePath), smoothTexture);

        return loadData(model, context, switch(Path.extension(assetPath).toLowerCase()) {
            case "dae": new DAEParser();
            case "md2": new MD2Parser();
            case "md5": new MD5MeshParser();
            case "awd": new AWDParser();
            default:    new OBJParser();
        }, (event:Asset3DEvent) -> {
            if (event.asset != null && event.asset.assetType == Asset3DType.MESH) {
                var mesh:Mesh = cast(event.asset, Mesh);
                if (material != null)
                    mesh.material = material;
            }
            callback(event);
        });
	}

    @:deprecated public function addMesh(assetPath:String, callback:Mesh->Void, ?texturePath:String, smoothTexture:Bool = true) {
        Logs.trace('The addMesh() function is deprecated!', ERROR, RED);
    }

    private var _loaders:Map<Asset3DLibraryBundle, AssetLoaderToken> = [];

    private function loadData(data:Dynamic, context:AssetLoaderContext, parser:ParserBase, onAssetCallback:Asset3DEvent->Void):AssetLoaderToken {
        var token:AssetLoaderToken;

        var lib:Asset3DLibraryBundle;
        lib = Asset3DLibraryBundle.getInstance(null);
        token = lib.loadData(data, context, null, parser);

        token.addEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetCallback);
        
        token.addEventListener(LoaderEvent.RESOURCE_COMPLETE, (_) -> { // Dispose loader when done
            trace("Disposing Loader...");
            _loaders.remove(lib);

            lib = null;
            token = null;
        });

        _loaders.set(lib,token);

        return token;
    }

    override function destroy() {
        super.destroy();

        for (loader => token in _loaders) {
            _loaders.remove(loader);

            loader = null;
            token = null;
        }
    }
}

typedef ModelQueueItem = {
    var assetPath:String;
    var callback:Asset3DEvent->Void;
    var texturePath:String;
}