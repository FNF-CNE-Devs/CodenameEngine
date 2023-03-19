package funkin.editors.ui;

import funkin.editors.ui.UIContextMenu.UIContextMenuOption;

class UITopMenu extends UISliceSprite {
    var options:Array<UIContextMenuOption>;
    public function new(options:Array<UIContextMenuOption>) {
        this.options = options;
        super(0, 0, FlxG.width, 25, 'editors/ui/topmenu');
        scrollFactor.set(0, 0);

        var x:Int = 0;
        for(o in options) {
            var b:UIButton = null;
            b = new UIButton(x, 0, o.label, function() {
                UIState.state.openContextMenu(o.childs, null, b.x, b.y + b.bHeight);
            }, 0, 23);
            b.resize(b.field.frameWidth + 8, b.bHeight);
            x += b.bWidth;
            members.push(b);
        }
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        bWidth = FlxG.width;
    }
}