package funkin.editors;

import flixel.math.FlxPoint;


class EditorPicker extends MusicBeatSubstate {
    public var bg:FlxSprite;

    public var options:Array<Editor> = [
        {
            name: "Chart Editor",
            iconID: 0,
            state: null
        },
        {
            name: "Character Editor",
            iconID: 1,
            state: null
        },
        {
            name: "Stage Editor",
            iconID: 2,
            state: null
        },
        {
            name: "Unknown Editor",
            iconID: 3,
            state: null
        },
        {
            name: "Unknown Editor",
            iconID: 3,
            state: null
        },
        {
            name: "Unknown Editor",
            iconID: 3,
            state: null
        }
    ];

    public var sprites:Array<EditorPickerOption> = [];

    public var curSelected:Int = 0;


    public var oldMousePos:FlxPoint = FlxPoint.get();
    public var curMousePos:FlxPoint = FlxPoint.get();

    public var optionHeight:Float = 0;

    public override function create() {
        super.create();

        camera = new FlxCamera();
        camera.bgColor = 0;
        FlxG.cameras.add(camera);

        bg = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
        bg.scale.set(FlxG.width, FlxG.height);
        bg.updateHitbox();
        bg.alpha = 0;
        add(bg);

        optionHeight = FlxG.height / options.length;
        for(k=>o in options) {
            var spr = new EditorPickerOption(o.name, o.iconID, optionHeight);
            spr.y = k * optionHeight;
            add(spr);
            sprites.push(spr);
        }
        sprites[0].selected = true;

        FlxG.mouse.getScreenPosition(camera, oldMousePos);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        bg.alpha = CoolUtil.fpsLerp(bg.alpha, 0.5, 0.25);
        changeSelection(-FlxG.mouse.wheel + (controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0));
        
        FlxG.mouse.getScreenPosition(camera, curMousePos);
        if (curMousePos.x != oldMousePos.x || curMousePos.y != oldMousePos.y) {
            oldMousePos.set(curMousePos.x, curMousePos.y);
            curSelected = -1;
            changeSelection(Std.int(curMousePos.y / optionHeight)+1);
        }
    }

    public function changeSelection(change:Int) {
        if (change == 0) return;

        curSelected = FlxMath.wrap(curSelected + change, 0, sprites.length-1);

        for(o in sprites)
            o.selected = false;
        sprites[curSelected].selected = true;
    }
}

typedef Editor = {
    var name:String;
    var iconID:Int;
    var state:Class<MusicBeatState>;
}

class EditorPickerOption extends FlxTypedSpriteGroup<FlxSprite> {
    public var iconSpr:FlxSprite;
    public var label:Alphabet;

    public var selectionBG:FlxSprite;

    public var selected:Bool = false;

    public var selectionLerp:Float = 0;

    public var iconRotationCycle:Float = 0;
    public function new(name:String, iconID:Int, height:Float) {
        super();


        FlxG.mouse.visible = true;
        iconSpr = new FlxSprite();
        iconSpr.loadGraphic(Paths.image('editors/icons'), true, 128, 128);
        iconSpr.animation.add("icon", [iconID], 24, true);
        iconSpr.animation.play("icon");
        iconSpr.antialiasing = true;
        if (height < 150) {
            iconSpr.scale.set(height / 150, height / 150);
            iconSpr.updateHitbox();
        }
        iconSpr.x = 25 + ((height - iconSpr.width) / 2);
        iconSpr.y = (height - iconSpr.height) / 2;

        label = new Alphabet(25 + iconSpr.width + 25, 0, name, true);
        label.y = (height - label.height) / 2;

        selectionBG = new FlxSprite().makeGraphic(1, 1, -1);
        selectionBG.scale.set(FlxG.width, height);
        selectionBG.updateHitbox();
        selectionBG.alpha = 0;

        add(selectionBG);
        add(iconSpr);
        add(label);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        iconRotationCycle += elapsed;

        selectionLerp = CoolUtil.fpsLerp(selectionLerp, selected ? 1 : 0, 0.25);

        selectionBG.alpha = (iconSpr.alpha = FlxEase.cubeOut(selectionLerp)) * 0.5;
        selectionBG.x = FlxMath.lerp(-FlxG.width, 0, selectionLerp);
        
        label.x = FlxMath.lerp(10, 25 + iconSpr.width + 25, selectionLerp);
        iconSpr.x = label.x - 25 - iconSpr.width;
        iconSpr.angle = Math.sin(iconRotationCycle * 0.5) * 5;

        scrollFactor.set(selectionLerp, 0);
    }

    public override function destroy() {
        super.destroy();
    }
}