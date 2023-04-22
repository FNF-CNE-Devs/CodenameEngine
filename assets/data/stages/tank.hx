var tankAngle:Float = FlxG.random.int(-90, 45);
var tankSpeed:Float = FlxG.random.float(5, 7);

function update(elapsed:Float) {
	tankAngle += elapsed * tankSpeed;
	tankRolling.angle = tankAngle - 90 + 15;
	tankRolling.x = 400 + (1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180)));
	tankRolling.y = 1300 + (1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180)));
}