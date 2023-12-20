import flixel.addons.util.FlxSimplex;

static var roses_shouldPlayOnThorns = false;
var self = this;
__script__.setParent(PlayState.instance);

var scream:FlxSound;
var senpaiEvil:FlxSprite;
var dfx = 0;
var dfy = 0;
function create() {
	// Cutscene stuff
	if(!roses_shouldPlayOnThorns) {
		disableScript();
		self.close();
		return;
	}
	roses_shouldPlayOnThorns = false;
	camHUD.visible = false;

	var red:FlxSprite = new FlxSprite().makeSolid(FlxG.width + 100, FlxG.height + 100, 0xFFff1b31);
	red.screenCenter();
	red.scrollFactor.set();
	add(red);

	senpaiEvil = new FlxSprite();
	senpaiEvil.frames = Paths.getSparrowAtlas('game/cutscenes/weeb/senpaiCrazy');
	senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
	senpaiEvil.animation.play('idle');
	senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * daPixelZoom));
	senpaiEvil.scrollFactor.set();
	senpaiEvil.updateHitbox();
	senpaiEvil.screenCenter();
	senpaiEvil.x += daPixelZoom * 51;
	dfx = senpaiEvil.x;
	dfy = senpaiEvil.y;
	add(senpaiEvil);

	var white:FlxSprite = new FlxSprite().makeSolid(FlxG.width + 100, FlxG.height + 100, FlxColor.WHITE);
	white.screenCenter();
	white.scrollFactor.set();
	white.alpha = 0;
	add(white);

	new FlxTimer().start(3.2, function(deadTime:FlxTimer)
	{
		FlxG.camera.fade(FlxColor.WHITE, 1.6, false, function() {
			remove(senpaiEvil, true);
			senpaiEvil.destroy();
			remove(red, true);
			red.destroy();

			white.alpha = 1;
		});
	});
	scream = FlxG.sound.play(Paths.sound('cutscenes/weeb/Senpai_Dies'), 1, false, null, true, function()
	{
		new FlxTimer().start(0.2, function(swagTimer:FlxTimer) {
			white.alpha -= 0.15;

			if(white.alpha > 0) swagTimer.reset();
			else {
				remove(white, true);
				white.destroy();

				camHUD.visible = true;
				self.close();
			}
		});

		FlxG.camera.fade(FlxColor.WHITE, 0.0001, true);
	});
}

var sVal = 0;
var seed = FlxG.random.float(-4000, 4000);
var sShkv = 50; // shake range
var sSpeed = 240;

function update(elapsed:Float) {
	if(scream?.time > 2350) {
		sVal += sSpeed * elapsed;

		var vx = sShkv * FlxSimplex.simplexOctaves(sVal, seed, 0.07, 0.25, 4);
		var vy = sShkv * FlxSimplex.simplexOctaves(sVal + 500, seed, 0.07, 0.25, 4);

		senpaiEvil.setPosition(dfx + vx, dfy + vy);
	}
}