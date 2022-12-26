package funkin.desktop.editors;

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

    /**
     * ANIMATION TAB
     */
    public var animsDropDown:DropDown;
    public var animNameInput:InputBox;
    public var animPrefixInput:InputBox;

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

        var labels:Array<WindowText> = [];
        var label:WindowText = null;

        labels.push(label = new WindowText(10, 10, 0, "Animations"));
        animsDropDown = new DropDown(10, label.y + label.height, 380, [], function(id) {
            changeAnim(id);
        });

        labels.push(label = new WindowText(10, animsDropDown.y + animsDropDown.height + 10, 0, "Animation Name"));
        animNameInput = new InputBox(10, label.y + label.height, 380, "");

        labels.push(label = new WindowText(10, animNameInput.y + animNameInput.height + 10, 0, "Animation Prefix"));
        animPrefixInput = new InputBox(10, label.y + label.height, 380, "");

        // labels.push(label = new WindowText(10, animNameInput.y + animNameInput.height + 10, 0, "Animation Prefix"));
        // animPrefixInput = new InputBox(10, label.y + label.height, 380, "");
        
        for(l in labels)
            tabView.tabs[0].add(l);

        for(spr in [animsDropDown, animNameInput, ])
            tabView.tabs[0].add(spr);

        refreshAnims();
    }

    public function changeAnim(id:Int) {
        var anim = animList[id];
        if (anim == null) return;
        char.playAnim(anim.name, true);

        animNameInput.text = anim.name;
        animPrefixInput.text = anim.name;
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
    }

    public override function onWindowResize(width:Int, height:Int) {
        tabView.resize(400, height - 20);
    }
}