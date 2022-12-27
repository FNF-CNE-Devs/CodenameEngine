package funkin.desktop.editors;

import flixel.FlxBasic;
import funkin.game.Character;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.FlxG;

using funkin.system.XMLUtil;

class CharacterEditor extends WindowContent {
    public function new(curCharacter:String) {
        super('Character Editor - Loading...', 0, 0, 1200, 600);
    }

    public var camHUD:FlxCamera;
    public var char:Character;
    public var curCharacter:String;
    public var camFollow:FlxObject;
    public var tabView:TabView;

    public var animList:Array<AnimData> = [];
    public var animListNames:Array<String> = [];

    public var curAnim:AnimData;

    /**
     * ANIMATION TAB
     */
    public var animsDropDown:DropDown;
    public var animNameInput:InputBox;
    public var animPrefixInput:InputBox;
    public var animLoopCheckbox:Checkbox;
    public var animFpsStepper:NumericStepper;
    public var animOffsetX:NumericStepper;
    public var animOffsetY:NumericStepper;

    public override function create() {
        super.create();

        // camera stuff
        parent.windowCameras[0].resizeScroll = false;
        camHUD = new FlxCamera(0, 0, 1200, 600, 1);
        camHUD.pixelPerfectRender = true;
        camHUD.bgColor = 0;
        parent.addCamera(camHUD);

        // stage
        var bg = new FlxSprite(-600, -200).loadAnimatedGraphic(Paths.image('stages/default/stageback'));
        bg.scrollFactor.set(0.9, 0.9);

        var stageFront = new FlxSprite(-600, 600).loadAnimatedGraphic(Paths.image('stages/default/stagefront'));

        char = new Character(100, 100, curCharacter, false, false);

        for(e in [bg, stageFront])
            e.antialiasing = true;
        add(bg);
        add(stageFront);
        add(char);
        
        title = 'Character Editor - ${char.curCharacter}.xml';

        // character setup & following
        var charMidpoint = char.getGraphicMidpoint();
        camFollow = new FlxObject(0, 0, 2, 2);
        camFollow.setPosition(charMidpoint.x, charMidpoint.y);
        add(camFollow);
        windowCamera.follow(camFollow, LOCKON, 999);

        // loading animations from character
        animList = [];
        if (char.xml != null)
            for(anim in char.xml.nodes.anim)
                animList.push(anim.extractAnimFromXML());

        // interface setup
        setupTabView();
    }

    public function setupTabView() {
        tabView = new TabView(800, 20, 400, 580, ["Animation Settings", "Character Settings"]);
        tabView.updateAnchor(1, 0, [camHUD]);
        add(tabView);

        var content:Array<FlxBasic> = [];
        var label:WindowText = null;

        content.push(label = new WindowText(10, 10, 0, "Animations"));
        content.push(animsDropDown = new DropDown(10, label.y + label.height, 380, [], function(id) {
            changeAnim(id);
        }));

        content.push(label = new WindowText(10, animsDropDown.y + animsDropDown.height + 10, 0, "Animation Name"));
        content.push(animNameInput = new InputBox(10, label.y + label.height, 380, ""));

        content.push(label = new WindowText(10, animNameInput.y + animNameInput.height + 10, 0, "Animation Prefix"));
        content.push(animPrefixInput = new InputBox(10, label.y + label.height, 380, ""));

        content.push(animLoopCheckbox = new Checkbox(10, animPrefixInput.y + animPrefixInput.height + 10, 380, "Loop"));
        
        content.push(label = new WindowText(10, animLoopCheckbox.y + animLoopCheckbox.height + 10, 0, "Animation FPS (Frames per second)"));
        content.push(animFpsStepper = new NumericStepper(10, label.y + label.height + 10, 380, 0));

        content.push(label = new WindowText(10, animFpsStepper.y + animFpsStepper.height + 10, 0, "Animation Offset (Relative to scale)"));
        content.push(animOffsetX = new NumericStepper(10, label.y + label.height + 10, 180, 0));
        content.push(animOffsetY = new NumericStepper(200, label.y + label.height + 10, 180, 0));
        
        for(spr in content)
            tabView.tabs[0].add(spr);

        refreshAnims();
        changeAnim(0);
    }

    public function changeAnim(id:Int) {
        curAnim = animList[id];
        if (curAnim == null) return;
        char.playAnim(curAnim.name, true);

        animNameInput.text = curAnim.name;
        animPrefixInput.text = curAnim.anim;
        animLoopCheckbox.setChecked(curAnim.loop);
        animFpsStepper.value = curAnim.fps;
        animOffsetX.value = curAnim.x;
        animOffsetY.value = curAnim.y;
    }

    public function refreshAnims() {
        animListNames = [for(e in animList) e.name];
        animsDropDown.options = animListNames;
        animsDropDown.onSelectionChange(0);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (parent.focused) {
            if (FlxG.keys.pressed.RIGHT)    camFollow.x += elapsed * 500;
            if (FlxG.keys.pressed.LEFT)     camFollow.x -= elapsed * 500;
            if (FlxG.keys.pressed.DOWN)     camFollow.y += elapsed * 500;
            if (FlxG.keys.pressed.UP)       camFollow.y -= elapsed * 500;
        }

        if (curAnim != null) {
            // animation updating
            var shouldUpdate = false;
            var oldName:String = curAnim.name;

            var updateListAsWell = shouldUpdate = (curAnim.name != (curAnim.name = animNameInput.text));
            shouldUpdate = (curAnim.anim != (curAnim.anim = animPrefixInput.text)) || shouldUpdate;
            shouldUpdate = (curAnim.fps != (curAnim.fps = Std.int(animFpsStepper.value))) || shouldUpdate;
            shouldUpdate = (curAnim.loop != (curAnim.loop = animLoopCheckbox.checked)) || shouldUpdate;
            shouldUpdate = (curAnim.x != (curAnim.x = animOffsetX.value)) || shouldUpdate;
            shouldUpdate = (curAnim.y != (curAnim.y = animOffsetY.value)) || shouldUpdate;

            if (shouldUpdate)
                updateCurAnim(oldName, updateListAsWell);
        }
    }

    public function updateCurAnim(?oldName:String, updateListAsWell:Bool = false) {
        if (oldName == null)
            oldName = char.animation.curAnim != null ? char.animation.curAnim.name : curAnim.name;

        char.animation.remove(oldName);

        XMLUtil.addAnimToSprite(char, curAnim);

        char.playAnim(curAnim.name, true);
    }

    public override function onWindowResize(width:Int, height:Int) {
        tabView.resize(400, height - 20);
    }
}