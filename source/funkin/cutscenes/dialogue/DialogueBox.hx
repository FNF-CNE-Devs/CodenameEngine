package funkin.cutscenes.dialogue;

import openfl.utils.Assets;
import flixel.FlxG;
import flixel.math.FlxPoint;
import haxe.xml.Access;

class DialogueBox extends FunkinSprite {
    public var dialogueBoxData:Access;
    public var positions:Map<String, CharPosDef> = [];

    public function new(name:String) {
        super();
        try {
            dialogueBoxData = new Access(Xml.parse(Assets.getText(Paths.xml('dialogue/boxes/$name'))).firstElement());

            loadSprite(Paths.image('dialogue/boxes/${dialogueBoxData.getAtt('sprite').getDefault(name)}'));

            for(anim in dialogueBoxData.nodes.anim) {
                if (!anim.has.name) continue;
                XMLUtil.addXMLAnimation(this, anim);
            }

            for(pos in dialogueBoxData.nodes.charpos) {
                if (!pos.has.name) continue;
                positions[pos.att.name] = {
                    x: pos.has.x ? Std.parseFloat(pos.att.x).getDefault(0) : 0,
                    y: pos.has.y ? Std.parseFloat(pos.att.y).getDefault(0) : 0,
                    flipBubble: pos.getAtt('flipBubble') == "true"
                };
            }

            antialiasing = dialogueBoxData.getAtt("antialiasing").getDefault("true") == "true";
            screenCenter(X);
            y = FlxG.height - height;
            if (dialogueBoxData.has.x) x += Std.parseFloat(dialogueBoxData.att.x).getDefault(0);
            if (dialogueBoxData.has.y) y += Std.parseFloat(dialogueBoxData.att.y).getDefault(0);
            visible = false;
        } catch(e) {
            active = false;
            Logs.trace('Couldn\'t load dialogue box "$name": ${e.toString()}', ERROR);
        }
    }

    public function popupChar(char:DialogueCharacter) {
        if (!active) return;
        var pos = positions[char.positionName];
        if (pos == null) return;

        if (!char.visible) {
            char.alpha = 0;
            char.visible = true;
            char.setPosition(pos.x, pos.y + 100);
            char.show(pos.y);
        }
    }

    public function playBubbleAnim(bubble:String) {
        if (hasAnimation('$bubble-open'))
            playAnim('$bubble-open', true);
        else
            playAnim(bubble);
        visible = true;
    }

    public override function destroy() {
        super.destroy();
        positions = null;
    }
}

typedef CharPosDef = {
    var x:Float;
    var y:Float;
    var flipBubble:Bool;
}