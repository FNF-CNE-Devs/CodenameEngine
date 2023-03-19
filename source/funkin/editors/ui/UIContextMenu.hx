package funkin.editors.ui;

class UIContextMenu extends MusicBeatSubstate {
    var options:Array<UIContextMenuOption>;
    var x:Float;
    var y:Float;
    var contextCam:FlxCamera;

    var bg:UISpliceSprite;
    var callback:UIContextMenuCallback;

    public var contextMenuOptions:Array<UIContextMenuOptionSpr> = [];

    public function new(options:Array<UIContextMenuOption>, callback:UIContextMenuCallback, x:Float, y:Float) {
        super();
        this.options = options.getDefault([]);
        this.x = x;
        this.y = y;
        this.callback = callback;
    }

    public override function create() {
        super.create();
        camera = contextCam = new FlxCamera();
        contextCam.bgColor = 0;
        contextCam.alpha = 0;
        FlxG.cameras.add(contextCam, false);

        bg = new UISpliceSprite(x, y, 100, 100, 'editors/ui/context-bg');
        add(bg);

        var lastY:Float = bg.y + 4;
        for(o in options) {
            var spr = new UIContextMenuOptionSpr(bg.x + 4, lastY, o, this);
            lastY = spr.y + spr.bHeight;
            contextMenuOptions.push(spr);
            add(spr);
        }

        var maxW = bg.bWidth - 8;
        for(o in contextMenuOptions)
            if (o.bWidth > maxW)
                maxW = o.bWidth;

        
        for(o in contextMenuOptions)
            o.bWidth = maxW;
        bg.bWidth = maxW + 8;
        bg.bHeight = Std.int(lastY - bg.y + 4);
    }

    public function select(option:UIContextMenuOption) {
        var index = options.indexOf(option);
        if (option.onSelect != null)
            option.onSelect();
        if (callback != null)
            callback(this, index, option);
        close();
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

typedef UIContextMenuCallback = UIContextMenu->Int->UIContextMenuOption->Void;
typedef UIContextMenuOption = {
    var label:String;
    var ?icon:Int;
    var ?onSelect:Void->Void;
    var ?childs:Array<UIContextMenuOption>;
}

class UIContextMenuOptionSpr extends UISpliceSprite {
    public var label:UIText;
    public var option:UIContextMenuOption;

    var parent:UIContextMenu;

    public function new(x:Float, y:Float, option:UIContextMenuOption, parent:UIContextMenu) {
        label = new UIText(20, 2, 0, option.label);
        this.option = option;
        this.parent = parent;

        super(x, y, label.frameWidth + 22, label.frameHeight, 'editors/ui/button');
        members.push(label);
    }

    public override function draw() {
        alpha = hovered ? 1 : 0;
        label.follow(this, 20, 0);
        super.draw();
    }

    public override function onHovered() {
        super.onHovered();
        if (FlxG.mouse.justReleased)
            parent.select(option);
    }
}