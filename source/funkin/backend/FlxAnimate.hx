package funkin.backend;

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
			if (limb != _pivot) {
				if (frameOffsetAngle != null && frameOffsetAngle != angle)
				{
					var angleOff = (-angle + frameOffsetAngle) * FlxAngle.TO_RAD;
					rMatrix.rotate(-angleOff);
					rMatrix.translate(-frameOffset.x, -frameOffset.y);
					rMatrix.rotate(angleOff);
				}
				else
				{
					rMatrix.translate(-frameOffset.x, -frameOffset.y);
				}
				rMatrix.scale(scale.x, scale.y);

				if (!matrixExposed && bakedRotationAngle <= 0)
				{
					updateTrig();

					if (angle != 0)
						rMatrix.rotateWithTrig(_cosAngle, _sinAngle);
				}
			}
			else
				rMatrix.a = rMatrix.d = 0.7 / camera.zoom;

			if (matrixExposed)
			{
				rMatrix.concat(transformMatrix);
			}
			else
			{
				rMatrix.concat(@:privateAccess flxanimate.FlxAnimate._skewMatrix);
			}

			_point.addPoint(origin);
			if (isPixelPerfectRender(camera))
			{
				_point.floor();
			}

			rMatrix.translate(_point.x, _point.y);
			camera.drawPixels(limb, null, rMatrix, colorTransform, blend, antialiasing, shaderEnabled ? shader : null);
			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}

		// doesnt work, needs to be remade
		// #if FLX_DEBUG
		// if (FlxG.debugger.drawDebug)
		// 	drawDebug();
		// #end
	}

	override function limbOnScreen(limb:FlxFrame, m:FlxMatrix, ?Camera:FlxCamera)
	{
		// TODO: ACTUAL OPTIMISATION
		return true;
	}
}