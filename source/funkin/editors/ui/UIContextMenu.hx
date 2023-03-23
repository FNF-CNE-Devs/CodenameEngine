package funkin.editors.ui;

class UIContextMenu extends MusicBeatSubstate {
    public var options:Array<UIContextMenuOption>;
    var x:Float;
    var y:Float;
    var contextCam:FlxCamera;

    var bg:UISliceSprite;
    var callback:UIContextMenuCallback;

    public var contextMenuOptions:Array<UIContextMenuOptionSpr> = [];
    public var separators:Array<FlxSprite> = [];

    private var __oobDeletion:Bool = true;

    public inline function preventOutOfBoxClickDeletion() {
        __oobDeletion = false;
    }

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
        contextCam.scroll.set(0, 7.5);
        FlxG.cameras.add(contextCam, false);

        bg = new UISliceSprite(x, y, 100, 100, 'editors/ui/context-bg');
        add(bg);

        var lastY:Float = bg.y + 4;
        for(o in options) {
            if (o == null) {
                var spr = new FlxSprite(bg.x + 8, lastY + 2).makeGraphic(1, 1, -1);
                spr.alpha = 0.3;
                separators.push(spr);
                add(spr);
                lastY += 5;
                continue;
            }
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
        for(o in separators) {
            o.scale.set(maxW - 8, 1);
            o.updateHitbox();
        }
        bg.bWidth = maxW + 8;
        bg.bHeight = Std.int(lastY - bg.y + 4);

		if (bg.y + bg.bHeight > FlxG.height) {
			bg.y -= bg.bHeight;
			for(o in contextMenuOptions)
				o.y -= bg.bHeight;
		}
    }

    public function select(option:UIContextMenuOption) {
        var index = options.indexOf(option);
        if (option.onSelect != null)
            option.onSelect(option);
        if (callback != null)
            callback(this, index, option);
        close();
    }

    public override function update(elapsed:Float) {
        if (__oobDeletion && FlxG.mouse.pressed && !bg.hoveredByChild)
            close();

        __oobDeletion = true;

        super.update(elapsed);

        contextCam.scroll.y = CoolUtil.fpsLerp(contextCam.scroll.y, 0, 0.5);
        contextCam.alpha = CoolUtil.fpsLerp(contextCam.alpha, 1, 0.25);
    }

    public override function destroy() {
        super.destroy();
        FlxG.cameras.remove(contextCam);
        if (UIState.state.curContextMenu == this)
            UIState.state.curContextMenu = null;
    }
}

typedef UIContextMenuCallback = UIContextMenu->Int->UIContextMenuOption->Void;
typedef UIContextMenuOption = {
    var label:String;
    var ?icon:Int;
    var ?onSelect:UIContextMenuOption->Void;
    var ?childs:Array<UIContextMenuOption>;
}

class UIContextMenuOptionSpr extends UISliceSprite {
    public var label:UIText;
    public var option:UIContextMenuOption;

    var parent:UIContextMenu;

    public function new(x:Float, y:Float, option:UIContextMenuOption, parent:UIContextMenu) {
        label = new UIText(20, 2, 0, option.label);
        this.option = option;
        this.parent = parent;

        super(x, y, label.frameWidth + 22, label.frameHeight, 'editors/ui/menu-item');
        members.push(label);
    }

    public override function draw() {
        alpha = hovered ? 1 : 0;
        label.follow(this, 20, 2);
        super.draw();
    }

    public override function onHovered() {
        super.onHovered();
        if (FlxG.mouse.justReleased)
            parent.select(option);
    }
}