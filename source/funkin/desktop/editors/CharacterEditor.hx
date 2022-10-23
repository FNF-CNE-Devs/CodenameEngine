package funkin.desktop.editors;

import funkin.game.Character;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.FlxG;

class CharacterEditor extends WindowContent {
    public function new(curCharacter:String) {
        super('Character Editor - Loading...', 0, 0, 800, 600);
    }

    public var camHUD:FlxCamera;
    public var char:Character;
    public var curCharacter:String;
    public var camFollow:FlxObject;

    public override function create() {
        super.create();

        // camera stuff
        parent.windowCameras[0].resizeScroll = false;
        camHUD = new FlxCamera(800, 600, 1);
        camHUD.pixelPerfectRender = true;
        camHUD.bgColor = 0;
        parent.addCamera(camHUD);

        // stage
        var bg = new FlxSprite(-600, -200, Paths.image('stages/default/stageback'));
        bg.scrollFactor.set(0.9, 0.9);
        var stageFront = new FlxSprite(-600, 600, Paths.image('stages/default/stagefront'));
        stageFront.scrollFactor.set(0.9, 0.9);
        var stageCurtains = new FlxSprite(-500, -300, Paths.image('stages/default/stagecurtains'));
        stageCurtains.scrollFactor.set(1.3, 1.3);
        char = new Character(100, 100, curCharacter, false);

        for(e in [bg, stageFront, stageCurtains]) {
            e.antialiasing = true;
        }
        add(bg);
        add(stageFront);
        add(char);
        add(stageCurtains);
        
        // character setup & following
        camFollow = new FlxObject(0, 0, 2, 2);
        var charMidpoint = char.getGraphicMidpoint();
        camFollow.setPosition(charMidpoint.x, charMidpoint.y);
        add(camFollow);
        windowCamera.follow(camFollow, LOCKON, 999);
        title = 'Character Editor - ${char.curCharacter}.xml';
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (parent.focused) {
            if (FlxG.keys.pressed.RIGHT)    camFollow.x += elapsed * 200;
            if (FlxG.keys.pressed.LEFT)     camFollow.x -= elapsed * 200;
            if (FlxG.keys.pressed.DOWN)     camFollow.y += elapsed * 200;
            if (FlxG.keys.pressed.UP)       camFollow.y -= elapsed * 200;
        }
    }
}