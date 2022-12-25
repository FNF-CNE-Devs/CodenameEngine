package funkin.desktop.sprites;

import flixel.FlxObject;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import flixel.FlxBasic;
import funkin.desktop.windows.WindowGroup;

class TabView extends WindowGroup<FlxBasic> {
    public var tabBG:SpliceSprite;
    public var tabButtons:Array<Button> = [];
    public var tabs:Array<WindowGroup<FlxBasic>> = [];
    public var bg:SpliceSprite;

    public var selectedTab:Int = 0;

    public var width:Float;
    public var height:Float;

    public function new(x:Float, y:Float, width:Float, height:Float, tabs:Array<String>) {
        super();
        this.x = x;
        this.y = y;

        var tabBG = DesktopMain.theme.tabBackground;
        bg = new SpliceSprite(Paths.image(tabBG.sprite), x, y, 75, 24, tabBG.left, tabBG.top, tabBG.bottom, tabBG.right);
        add(bg);
        for(k=>t in tabs) {
            // BUTTON
            var b = new Button(0, 0, t, function() {
                switchTab(k);
            }, DesktopMain.theme.tabButtonUnselected, DesktopMain.theme.tabButtonHover, DesktopMain.theme.tabButtonPressed, DesktopMain.theme.tabButtonSelected);

            tabButtons.push(b);
            add(b);

            // TAB
            var tab = new WindowGroup<FlxBasic>();
            tab.y += b.height;
            this.tabs.push(tab);
            add(tab);
        }
        resize(width, height);
        switchTab(0);
    }

    public function resize(width:Float, height:Float) {
        this.width = width;
        this.height = height;
        updateButtons();
        updateBG();
    }

    public function updateButtons() {
        var bWidth:Float = Math.floor(width / tabs.length);
        for(k=>b in tabButtons) {
            var w = (k >= tabs.length - 1) ? (width - (bWidth * (tabs.length - 1))) : bWidth;
            b.resize(w, 24);
            b.x = x + (k * bWidth);
        }
    }

    public function updateBG() {
        bg.x = x;
        bg.y = y + 24;
        bg.resize(width, height - 24);
    }

    public function switchTab(id:Int) {
        selectedTab = id;
        for(k=>b in tabButtons)
            b.disabled = k == selectedTab;
    }

    public override function update(elapsed:Float) {
        bg.update(elapsed);
        for(e in tabButtons)
            e.update(elapsed);
        if (tabs[selectedTab] != null)
            tabs[selectedTab].update(elapsed);

        if (DesktopMain.mouseInput.overlapsRect(bg, new FlxRect(x, y, width, height), camera))
            DesktopMain.mouseInput.cancel();
    }

    public override function draw() {
        bg.draw();
        for(e in tabButtons)
            e.draw();
        if (tabs[selectedTab] != null)
            tabs[selectedTab].draw();
    }
}