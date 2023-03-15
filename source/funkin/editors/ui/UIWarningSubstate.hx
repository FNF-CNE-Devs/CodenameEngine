package funkin.editors.ui;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import funkin.shaders.CustomShader;

class UIWarningSubstate extends MusicBeatSubstate {
    var camShaders:Array<FlxCamera> = [];
    var blurShader:CustomShader = new CustomShader("editorBlur");

    var title:String;
    var message:String;
    var buttons:Array<WarningButton>;

    var titleSpr:UIText;
    var messageSpr:UIText;

    public override function onSubstateOpen() {
        super.onSubstateOpen();
        parent.persistentUpdate = false;
        parent.persistentDraw = true;
    }

    public override function create() {
        for(c in FlxG.cameras.list) {
            camShaders.push(c);
            c.addShader(blurShader);
        }

        camera = new FlxCamera();
        camera.bgColor = 0;
        camera.alpha = 0;
        camera.zoom = 0.1;
        FlxG.cameras.add(camera, false);

        var spr = new UISpliceSprite(0, 0, 560, 280, "editors/ui/warning-popup");
        spr.x = (FlxG.width - spr.bWidth) / 2;
        spr.y = (FlxG.height - spr.bHeight) / 2;
        add(spr);

        
        add(titleSpr = new UIText(spr.x + 25, spr.y, spr.bWidth - 50, title, 15, -1));
        titleSpr.y = spr.y + ((30 - titleSpr.height) / 2);
        
        add(messageSpr = new UIText(spr.x + 10, spr.y + 40, spr.bWidth - 20, message, 15, 0xFF000000));

        FlxTween.tween(camera, {alpha: 1}, 0.25, {ease: FlxEase.cubeOut});
        FlxTween.tween(camera, {zoom: 1}, 0.66, {ease: FlxEase.elasticOut});

        CoolUtil.playMenuSFX(WARNING);
    }

    public override function destroy() {
        super.destroy();
        for(e in camShaders)
            e.removeShader(blurShader);

        FlxG.cameras.remove(camera);
    }

    public function new(title:String, message:String, buttons:Array<WarningButton>) {
        super();
        this.title = title;
        this.message = message;
        this.buttons = buttons;
    }
}
typedef WarningCamShader = {
    var cam:FlxCamera;
}
typedef WarningButton = {
    var label:String;
    var onClick:UIWarningSubstate->Void;
}