import funkin.system.FunkinSprite;

var tankman:FunkinSprite;
function create() {
    game.camHUD.visible = false;

    tankman = new FunkinSprite(game.dad.x + game.dad.globalOffset.x + 520, game.dad.y + game.dad.globalOffset.y + 225);
    tankman.antialiasing = true;
    tankman.loadSprite(Paths.image('game/cutscenes/tank/ugh-tankman'));
    tankman.animateAtlas.anim.addBySymbol('1', 'TANK TALK 1 P1', 24, false);
    tankman.animateAtlas.anim.addBySymbol('2', 'TANK TALK 1 P2', 24, false);
    game.insert(game.members.indexOf(game.dad), tankman);

    game.dad.visible = false;

    tankman.playAnim('1');

    game.camFollow.setPosition(tankman.x, tankman.y);

    game.persistentUpdate = true;
}

function update(elapsed:Float) {
    if (FlxG.keys.justPressed.F5)
        FlxG.resetState();
}