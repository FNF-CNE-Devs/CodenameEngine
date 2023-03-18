package funkin.editors.ui;

class UIContextMenu extends MusicBeatSubstate {
    var options:Array<UIContextMenuOption>;
    var x:Float;
    var y:Float;
    var contextCam:FlxCamera;

    var bg:UISpliceSprite;

    public function new(options:Array<UIContextMenuOption>, x:Float, y:Float) {
        super();
        this.options = options.getDefault([]);
        this.x = x;
        this.y = y;
    }

    public override function create() {
        super.create();
        camera = contextCam = new FlxCamera();
        contextCam.bgColor = 0;
        contextCam.alpha = 0;
        FlxG.cameras.add(contextCam, false);

        bg = new UISpliceSprite(x, y, 100, 100, 'editors/ui/context-bg');
        add(bg);
    }

    public override function update(elapsed:Float) {
        if (FlxG.mouse.pressed && !bg.hoveredByChild)
            close();

        super.update(elapsed);

        contextCam.alpha = CoolUtil.fpsLerp(contextCam.alpha, 1, 0.25);
    }

    public override function destroy() {
        super.destroy();
        FlxG.cameras.remove(contextCam);
    }
}

typedef UIContextMenuOption = {
    var label:String;
    var ?icon:Int;
    var ?onSelect:Void->Void;
    var ?childs:Array<UIContextMenuOption>;
}

class UIContextMenuOptionSpr extends UISpliceSprite {
    public var label:UIText;
    public var option:UIContextMenuOption;

    public function new(x:Float, y:Float, option:UIContextMenuOption) {
        label = new UIText(20, 2, 0, option.label);
        this.option = option;

        super(x, y, label.frameWidth + 22, label.frameHeight + 4, 'editors/ui/button');
        members.push(label);
    }

    public override function draw() {
        alpha = hovered ? 1 : 0;
        label.follow(this, 20, 2);
        super.draw();
    }
}