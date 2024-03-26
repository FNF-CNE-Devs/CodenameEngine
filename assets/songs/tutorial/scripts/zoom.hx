var lastFocused:Int = null;
var zoomin:FlxTween = null;

function onNoteHit(event)
	event.enableCamZooming = false;

function onCameraMove(_) if(zoomin == null && lastFocused != (lastFocused = curCameraTarget))
	zoomin = FlxTween.tween(FlxG.camera, {zoom: curCameraTarget == 0 ? 1.3 : 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete: function(_) zoomin = null});