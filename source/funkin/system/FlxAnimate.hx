package funkin.system;

import flixel.graphics.frames.FlxFramesCollection;
import openfl.geom.ColorTransform;
import flixel.math.FlxMatrix;
import flixel.math.FlxAngle;
import flixel.math.FlxRect;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;

class FlxAnimate extends flxanimate.FlxAnimate {
	public static var loadedPaths:Array<String> = [];
	public override function loadAtlas(Path:String) {
		super.loadAtlas(Path);
		loadedPaths.push(Path);
	}

	public static function init() {
		FlxG.signals.preStateSwitch.add(onSwitch);
	}

	private static function onSwitch() {
		for(p in loadedPaths) {
			Assets.cache.clear(p);
		}
	}
	override function drawLimb(limb:FlxFrame, _matrix:FlxMatrix, ?colorTransform:ColorTransform)
	{
		if (alpha == 0 || colorTransform != null && (colorTransform.alphaMultiplier == 0 || colorTransform.alphaOffset == -255) || limb == null || limb.type == EMPTY)
			return;
		for (camera in cameras)
		{
			var matrix = new FlxMatrix();
			matrix.concat(_matrix);
			if (!camera.visible || !camera.exists || !limbOnScreen(limb, _matrix, camera))
				return;

			getScreenPosition(_point, camera).subtractPoint(offset);
			matrix.translate(-origin.x, -origin.y);
			if (limb.name != "pivot") {
				if (rotOffsetAngle != null && rotOffsetAngle != angle)
				{
					var angleOff = (-angle + rotOffsetAngle) * FlxAngle.TO_RAD;
					matrix.rotate(-angleOff);
					if (useOffsetAsRotOffset)
						matrix.translate(-offset.x, -offset.y);
					else
						matrix.translate(-rotOffset.x, -rotOffset.y);
					matrix.rotate(angleOff);
				}
				else
				{
					if (useOffsetAsRotOffset)
						matrix.translate(-offset.x, -offset.y);
					else
						matrix.translate(-rotOffset.x, -rotOffset.y);
				}
				matrix.scale(scale.x, scale.y);

				if (bakedRotationAngle <= 0)
				{
					updateTrig();

					if (angle != 0)
						matrix.rotateWithTrig(_cosAngle, _sinAngle);
				}
			}
			else
				matrix.a = matrix.d = 0.7 / camera.zoom;
			_point.addPoint(origin);
			if (isPixelPerfectRender(camera))
			{
				_point.floor();
			}

			matrix.translate(_point.x, _point.y);
			camera.drawPixels(limb, null, matrix, colorTransform, blend, antialiasing);
			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

	override function limbOnScreen(limb:FlxFrame, m:FlxMatrix, ?Camera:FlxCamera)
	{
		// TODO: ACTUAL OPTIMISATION
		return true;
	}
}