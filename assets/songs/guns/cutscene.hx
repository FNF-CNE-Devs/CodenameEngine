import funkin.system.FunkinSprite;

var tankman:FunkinSprite;
var tankTalk1, distorto:FlxSound;

function create() {
	FlxTween.tween(FlxG.camera, {zoom: 1}, 0.7, {ease: FlxEase.quadInOut});
	game.camHUD.visible = false;

	tankman = new FunkinSprite(game.dad.x + game.dad.globalOffset.x + 520, game.dad.y + game.dad.globalOffset.y + 225);
	tankman.antialiasing = true;
	tankman.loadSprite(Paths.image('game/cutscenes/tank/guns-tankman'));
	tankman.animateAtlas.anim.addBySymbol('tank', 'TANK TALK 2', 0, false);

	game.insert(game.members.indexOf(game.dad), tankman);
	game.dad.visible = false;

	focusOn(game.dad);
	game.persistentUpdate = true;

	tankTalk = FlxG.sound.load(Paths.sound('cutscenes/tank/guns'));

	distorto = FlxG.sound.load(Paths.music('DISTORTO'));
	distorto.volume = 0;
	distorto.play();
	distorto.fadeIn(5, 0, 0.5);

	tankman.playAnim('tank');
	tankTalk.play();

	new FlxTimer().start(4.1, function(ugly:FlxTimer)
	{
		FlxTween.tween(FlxG.camera, {zoom: game.defaultCamZoom * 1.4}, 0.4, {ease: FlxEase.quadOut});
		FlxTween.tween(FlxG.camera, {zoom: game.defaultCamZoom * 1.3}, 0.7, {ease: FlxEase.quadInOut, startDelay: 0.45});
		game.gf.playAnim('sad', false, "DANCE");
	});

	new FlxTimer().start(11, function(tmr:FlxTimer)
	{
		game.remove(tankman);
		tankman.destroy();

		game.camHUD.visible = true;
		game.dad.visible = true;
		distorto.fadeOut((Conductor.crochet / 1000) * 5, 0);
		FlxTween.tween(FlxG.camera, {zoom: game.defaultCamZoom}, 0.7, {ease: FlxEase.quadInOut, startDelay: 0});

		close();
	});
}

function focusOn(char) {
	var camPos = char.getCameraPosition();
	game.camFollow.setPosition(camPos.x, camPos.y);
	camPos.put();
}