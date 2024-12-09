var intensity = 5; // How far the camera moves on press, default is 5
                   // 5 = 50 Pixels
var speed = 66;    // pixelsPerSecond

var alignX = true; // Makes up and down movement 70% of left and right movement, defualt is true

var move = true;   // Do you want the camera to move? default is true (can also be toggled with "toggleMovePress" event)

























function onCameraMove(event) {
	if (event.position.x == dad.getCameraPosition().x && event.position.y == dad.getCameraPosition().y)
		{
			camTarget = "dad";
		}
	else if (event.position.x == boyfriend.getCameraPosition().x && event.position.y == boyfriend.getCameraPosition().y)
		{
			camTarget = "boyfriend";
		}

	if (dad.animation.curAnim.name == "idle" && boyfriend.animation.curAnim.name == "idle" && move) {} else
	{
		event.cancel();
	}
}
var inte = intensity*10;
var time = inte / speed;
var inteW = (intensity*10)* (alignX ? 0.7 : 1);
var posOffsets = [
		[-inte, 0],
		[0, inteW],
		[0, -inteW],
		[inte, 0]
	];
var pos = {
    x: 0,
    y: 0
};
var daTween;
function onNoteHit(event) {
    if (move) {
        if (camTarget == "dad")
            {
                if (daTween != null && daTween.active) {
                    daTween.cancel();
                }
                daTween = FlxTween.tween(camGame.scroll, {
                    x: dad.getCameraPosition().x + posOffsets[event.direction][0] - (FlxG.width/2), 
                    y: dad.getCameraPosition().y + posOffsets[event.direction][1] - (FlxG.height/2)
                }, 0.75, {ease: FlxEase.quadOut, onStart: function() {
                    camFollow.setPosition(dad.getCameraPosition().x, dad.getCameraPosition().y);
                }});
            }
        else if (camTarget == "boyfriend")
            {
                if (daTween != null && daTween.active) {
                    daTween.cancel();
                }
                daTween = FlxTween.tween(camGame.scroll, {
                    x: boyfriend.getCameraPosition().x + posOffsets[event.direction][0] - (FlxG.width/2) + 30, 
                    y: boyfriend.getCameraPosition().y + posOffsets[event.direction][1] - (FlxG.height/2)
                }, 0.75, {ease: FlxEase.quadOut, onStart: function() {
                    camFollow.setPosition(boyfriend.getCameraPosition().x, boyfriend.getCameraPosition().y);
                }});
                //pos.setPosition(boyfriend.getCameraPosition().x + posOffsets[event.direction][0], boyfriend.getCameraPosition().y + posOffsets[event.direction][1]);
            }
    }
}
function updatePost() {
    camFollow.setPosition(pos.x, pos.y);
    camFollow.snapToTarget();
}
function toggleMovePress(event) {
    move = !move;
}