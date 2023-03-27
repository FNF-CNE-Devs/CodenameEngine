package funkin.system;

import flixel.graphics.frames.FlxFramesCollection;
import openfl.geom.ColorTransform;
import flixel.math.FlxMatrix;
import flixel.math.FlxAngle;
import flixel.math.FlxRect;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;

class FlxAnimate extends flxanimate.FlxAnimate {
	static var rMatrix = new FlxMatrix();

	override function drawLimb(limb:FlxFrame, _rMatrix:FlxMatrix, ?colorTransform:ColorTransform)
	{
		if (alpha == 0 || colorTransform != null && (colorTransform.alphaMultiplier == 0 || colorTransform.alphaOffset == -255) || limb == null || limb.type == EMPTY)
			return;
		for (camera in cameras)
		{
			rMatrix.identity();
			rMatrix.translate(-limb.offset.x, -limb.offset.y);
			rMatrix.concat(_rMatrix);
			if (!camera.visible || !camera.exists || !limbOnScreen(limb, _rMatrix, camera))
				return;

			getScreenPosition(_point, camera).subtractPoint(offset);
			rMatrix.translate(-origin.x, -origin.y);
			if (limb.name != "pivot") {
				if (rotOffsetAngle != null && rotOffsetAngle != angle)
				{
					var angleOff = (-angle + rotOffsetAngle) * FlxAngle.TO_RAD;
					rMatrix.rotate(-angleOff);
					if (useOffsetAsRotOffset)
						rMatrix.translate(-offset.x, -offset.y);
					else
						rMatrix.translate(-rotOffset.x, -rotOffset.y);
					rMatrix.rotate(angleOff);
				}
				else
				{
					if (useOffsetAsRotOffset)
						rMatrix.translate(-offset.x, -offset.y);
					else
						rMatrix.translate(-rotOffset.x, -rotOffset.y);
				}
				rMatrix.scale(scale.x, scale.y);

				if (bakedRotationAngle <= 0)
				{
					updateTrig();

					if (angle != 0)
						rMatrix.rotateWithTrig(_cosAngle, _sinAngle);
				}
			}
			else
				rMatrix.a = rMatrix.d = 0.7 / camera.zoom;
			
			//rMatrix.concat(_skewMatrix);

			_point.addPoint(origin);
			if (isPixelPerfectRender(camera))
			{
				_point.floor();
			}

			rMatrix.translate(_point.x, _point.y);
			camera.drawPixels(limb, null, rMatrix, colorTransform, blend, antialiasing);
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