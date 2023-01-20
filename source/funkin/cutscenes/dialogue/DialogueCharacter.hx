package funkin.cutscenes.dialogue;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.utils.Assets;
import haxe.xml.Access;

class DialogueCharacter extends FunkinSprite {
    public var charData:Access;
    public var curTween:FlxTween;
    public var positionName:String;

    public function new(name:String, position:String) {
        super();
        this.positionName = position;
        try {
            charData = new Access(Xml.parse(Assets.getText(Paths.xml('dialogue/characters/$name'))).firstElement());
            loadSprite(Paths.image('dialogue/characters/${charData.getAtt('sprite').getDefault(name)}'));
            antialiasing = charData.getAtt('antialiasing').getDefault('true') == 'true';
            offset.set(
                charData.has.x ? Std.parseFloat(charData.att.x).getDefault(0) : 0,
                charData.has.y ? Std.parseFloat(charData.att.y).getDefault(0) : 0);
            scale.scale(charData.has.scale ? Std.parseFloat(charData.att.scale).getDefault(1) : 1);
            for(anim in charData.nodes.anim)
                XMLUtil.addXMLAnimation(this, anim, true);
        } catch(e) {
            Logs.trace('Failed to load dialogue character $name: ${e.toString()}', ERROR);
        }
        visible = false;
    }

    public function show(y:Float) {
        if (curTween != null)
            curTween.cancel();

        curTween = FlxTween.tween(this, {alpha: 1, y: y}, 0.5, {ease: FlxEase.cubeOut});
    }
}