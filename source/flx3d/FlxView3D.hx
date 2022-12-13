package flx3d;

import away3d.entities.Mesh;
import funkin.system.Main;
import away3d.containers.View3D;
import away3d.events.LoaderEvent;
import away3d.library.assets.IAsset;
import away3d.loaders.Loader3D;
import away3d.loaders.misc.AssetLoaderContext;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.display.BitmapData;

/**
 * @author Ne_Eo 
 * @see https://twitter.com/Ne_Eo_Twitch
 * 
 * Edited by lunarclient
 * @see https://twitter.com/lunarcleint
 */
class FlxView3D extends FlxSprite
{
	public var view:View3D;

	@:noCompletion private var bmp:BitmapData;

	private var _loader:Loader3D;
	private var assetLoaderContext:AssetLoaderContext = new AssetLoaderContext();

	public function new(x:Float = 0, y:Float = 0, width:Int = -1, height:Int = -1, scale:Float = 1)
	{
		super(x, y);

		frameRate = 60;

		view = new View3D();
		view.visible = false;
		Main.instance.addChildAt(view, 0);

		view.width = width == -1 ? FlxG.width : width;
		view.height = height == -1 ? FlxG.height : height;
		view.backgroundAlpha = 0;
		bmp = new BitmapData(Std.int(view.width), Std.int(view.height), true, 0x0);

		loadGraphic(bmp);
	}

	private function dispose<T:IAsset>(obj:Null<T>):T // ! CALL THIS WHEN YOU DESTROY YOUR SCENE
	{
		if (obj != null)
		{
			obj.dispose();
		}
		return null;
	}

	override function destroy()
	{
		Main.instance.removeChild(view);
		view.dispose();
		_loader.disposeWithChildren();
		super.destroy();
		if (bmp != null)
		{
			bmp.dispose();
			bmp = null;
		}
		view = null;
		assetLoaderContext = null;
	}

	@:isVar public var frameRate(default, set):Float;

	public function set_frameRate(value:Float)
	{
		delay = 1 / value;
		return frameRate = value;
	}

	public var renderEveryFrame:Bool = true;

	@:noCompletion private var delay:Float = 0;
	@:noCompletion private var drawTimer:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		drawTimer += elapsed;
	}

	override function draw()
	{
		super.draw();

		if (renderEveryFrame || drawTimer > delay)
		{
			Main.instance.addChildAt(view, 0);
			var old = FlxG.game.filters;
			FlxG.game.filters = null;
			view.renderer.queueSnapshot(bmp);
			view.render();
			drawTimer = 0;
			FlxG.game.filters = old;
			Main.instance.removeChild(view);
		}
	}
}
