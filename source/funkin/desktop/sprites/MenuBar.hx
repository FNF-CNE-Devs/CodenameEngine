package funkin.desktop.sprites;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.FlxBasic;
import funkin.desktop.windows.WindowGroup;

class MenuBar extends WindowGroup<FlxBasic> {
    public var spr:FlxSprite;
    public var buttons:Array<Button> = [];
    public function new(trees:Array<TopMenuTree>) {
        super();

        spr = new FlxSprite(0, 0);
        spr.loadGraphic(Paths.image(DesktopMain.theme.menuBar.sprite));
        add(spr);

        var lastX:Float = 0;
        for(t in trees) {
            var b:Button = null;
            b = new Button(lastX, 0, t.name, function() {
                var pos:FlxPoint = b.getScreenPosition(null, camera);
                pos.y += b.height;
                
                var camPos = camera != null ? FlxPoint.get(camera.x, camera.y) : FlxPoint.get();
        
                ContextMenu.open(pos.x + camPos.x, pos.y + camPos.y, t.options, function(i) {});
                
                pos.put();
            });
            b.label.fieldWidth = 0;
            @:privateAccess b.label._regen = true;

            b.resize(b.label.width + 20, 20);
            lastX = b.x + b.width;

            b.normalSprite.visible = false;
            buttons.push(b);
            add(b);
        }
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        
        spr.setGraphicSize(FlxG.width, 20);
        spr.updateHitbox();
    }
}

typedef TopMenuTree = {
    var name:String;
    var options:Array<ContextOption>;
}