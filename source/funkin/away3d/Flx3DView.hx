package funkin.away3d;

import away3d.loaders.parsers.OBJParser;
import away3d.events.Asset3DEvent;
import openfl.utils.ByteArray;
import flixel.util.typeLimit.OneOfTwo;
import away3d.entities.Mesh;
import openfl.utils.Assets;
import hscript.Bytes;
import openfl.display.Sprite;
import flixel.FlxG;
import flixel.FlxObject;
import away3d.containers.View3D;
import away3d.loaders.Loader3D;
import away3d.loaders.misc.AssetLoaderToken;
import away3d.loaders.misc.AssetLoaderContext;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import haxe.io.Path;

class Flx3DView extends FlxSprite {
    // STATIC STUFF
    #if REGION
    private static var __sprite:Sprite;

    public static function init() {
        __sprite = new Sprite();
        FlxG.stage.addChild(__sprite);
    }
    #end

    private var __bitmap:BitmapData;
    private var __loader:Loader3D = new Loader3D();

    public var view3d:View3D;

    public var meshes:Array<Mesh> = [];

    public function new(x:Float, y:Float, width:Int = 0, height:Int = 0) {
        super(x, y);
        __loader.addEventListener(Asset3DEvent.ASSET_COMPLETE, assetComplete);
        view3d = new View3D();
        view3d.scene.addChild(__loader);

        if (width <= 0) width = FlxG.width;
        if (height <= 0) height = FlxG.height;

        resizeBitmap(width, height);

        __sprite.addChild(view3d);
    }

    public function assetComplete(event:Asset3DEvent) {
        
    }

    public function loadMesh(asset:String, callback:Mesh->Void) {
        try {
            var meshContent:ByteArrayData = Assets.getBytes(asset);
            
            if (meshContent == null)
                throw "Mesh Asset is null or does not exist.";
    
            var context = new AssetLoaderContext();

            var mtlPath = '${Path.withoutExtension(asset)}.mtl';
            trace(Path.withoutDirectory(mtlPath));
            context.mapUrlToData(Path.withoutDirectory(mtlPath), Assets.getBytes(mtlPath));

            var token = __loader.loadData(meshContent, context, null, new OBJParser());
            token.addEventListener(Asset3DEvent.MESH_COMPLETE, function(ev:Asset3DEvent) {
                if (ev.asset is Mesh) {
                    var mesh:Mesh = cast ev.asset;
                    addMesh(mesh);
                    callback(mesh);
                }
            });
        } catch(e) {
            trace(e.details());
        }
    }

    public function addMesh(mesh:Mesh) {
        if (mesh == null) return;

        meshes.push(mesh);
    }


    private function resizeBitmap(width:Int, height:Int) {
        if (__bitmap != null)
            __bitmap.dispose();
        __bitmap = new BitmapData(width, height, true, 0);
        loadGraphic(__bitmap);
    }

    public override function draw() {
        var filters = FlxG.game.filters;
        FlxG.game.filters = null;
        view3d.renderer.queueSnapshot(__bitmap);
        view3d.render();
        FlxG.game.filters = filters;

        super.draw();
    }

    public override function destroy() {
        __sprite.removeChild(view3d);

        view3d.dispose();
        super.destroy();
    }
}