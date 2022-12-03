package funkin.mods;

import sys.FileSystem;
import lime.utils.UInt8Array;
import lime.graphics.ImageBuffer;
import openfl.utils.ByteArray;
import openfl.utils.Assets;
import sys.io.File;

class PngBinHandler {
    public static function loadBinPng(path:String) {
        #if sys
        var bytes = File.getBytes('$path.bin');

        var width:Int = bytes.getInt32(0);
        var height:Int = bytes.getInt32(4);
        var bitsPerPixel:Int = bytes.getUInt16(8);
        var pixelFormat:Int = bytes.getUInt16(10);

        var imageBuffer = new ImageBuffer(UInt8Array.fromBytes(bytes, 12), width, height, bitsPerPixel, pixelFormat);

        return imageBuffer;
        #else
        return null;
        #end
    }

    public static function saveBinPng(buffer:ImageBuffer, path:String) {
        #if sys
        var array = new ByteArrayData(buffer.data.length + 12);
        array.writeInt(buffer.width);
        array.writeInt(buffer.height);
        array.writeShort(buffer.bitsPerPixel);
        array.writeShort(buffer.format);
        array.writeBytes(buffer.data.toBytes());
        File.saveBytes('$path.bin', array);
        #end
    }

    public static function exists(path:String) {
        #if sys
        return FileSystem.exists('$path.bin');
        #else
        return false;
        #end
    }
}