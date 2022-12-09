package funkin.away3d;

import away3d.core.base.Geometry;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import away3d.loaders.Loader3D;
import haxe.io.Bytes;
import flixel.util.typeLimit.OneOfTwo;
import away3d.entities.Mesh;

class FlxMesh extends Mesh implements IFlxDestroyable implements Flx3DObject {
    var __loader:Loader3D = new Loader3D();
    public function new(asset:OneOfTwo<Bytes, String>, textures:Array<String> = null) {
        if (textures == null) textures = [];

        var meshContent:Bytes = null;
        if (asset is String)
            meshContent = Assets.getBytes(asset);
        else if (asset is Bytes)
            meshContent = cast(asset, Bytes);
        if (meshContent == null)
            throw "Mesh Asset is null or does not exist.";

        __loader.loadData(meshContent);
        super(__loader.loadData());
    }

    public function destroy() {
        loader.dispose();
    }
}