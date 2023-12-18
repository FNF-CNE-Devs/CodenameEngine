import flixel.addons.effects.FlxTrail;

var self = this;
var trail:FlxTrail;
function postCreate() {
	trail = new FlxTrail(self, null, 4, 24, 0.3, 0.069);
}

function update(elpased) {
	// Makes it everytime go behind spirit
	PlayState.instance.insert(PlayState.instance.members.indexOf(self) - 1, trail);
}