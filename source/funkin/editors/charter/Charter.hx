package funkin.editors.charter;

import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import funkin.editors.ui.UIContextMenu.UIContextMenuOption;
import funkin.editors.ui.UIState;

class Charter extends UIState {
    var __song:String;
    var __diff:String;

    /**
     * CONFIG (might make this customizable later)
     */
    private var gridColor1:FlxColor = 0xFF404040; // white
    private var gridColor2:FlxColor = 0xFF212121; // gray

    public var topMenu:Array<UIContextMenuOption> = [
        {
            label: "File",
            childs: [
                {
                    label: "New"
                },
                null,
                {
                    label: "Exit",
                    onSelect: function() {
                        FlxG.switchState(new CharterSelection());
                    }
                }
            ]
        },
        {
            label: "Edit",
            childs: [
                {
                    label: "Undo"
                },
                {
                    label: "Redo"
                },
                null,
                {
                    label: "Cut"
                },
                {
                    label: "Copy"
                },
                {
                    label: "Paste"
                },
                null,
                {
                    label: "Delete"
                }
            ]
        },
        {
            label: "Chart",
            childs: [
                {
                    label: "Playtest"
                },
                {
                    label: "Playtest here"
                },
                null,
                {
                    label: "Playtest as opponent"
                },
                {
                    label: "Playtest as opponent here"
                },
                null,
                {
                    label: "Edit metadata information"
                }
            ]
        },
        {
            label: "Playback",
            childs: [
                {
                    label: "Play/Pause"
                },
                null,
                {
                    label: "Go back a section"
                },
                {
                    label: "Go forward a section"
                },
                null,
                {
                    label: "Go back to the start"
                }
            ]
        }
    ];

    public var topMenuSpr:UITopMenu;
    public var gridBackdrop:FlxBackdrop;

    public function new(song:String, diff:String) {
        super();
        __song = song;
        __diff = diff;
    }

    public override function create() {
        super.create();
        trace('Entering Charter for song $__song with difficulty $__diff.');
        CoolUtil.loadSong(__song, __diff, false, false);

        gridBackdrop = new FlxBackdrop(null, 1, 1, true, true);
        gridBackdrop.makeGraphic(4, 4, gridColor1, true);
        gridBackdrop.pixels.lock();
        for(y in 0...4)
            for(x in 0...2)
                gridBackdrop.pixels.setPixel32((x*2)+(y%2), y, gridColor2);
        gridBackdrop.pixels.unlock();
        gridBackdrop.scale.set(40, 40);
        gridBackdrop.updateHitbox();
        gridBackdrop.loadFrame(gridBackdrop.frame);
        gridBackdrop.cameras = cameras;
        add(gridBackdrop);


        // ALWAYS ADD LAST
        topMenuSpr = new UITopMenu(topMenu);
        add(topMenuSpr);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        // TODO: remove this bs!!
        if (controls.BACK)
            FlxG.switchState(new funkin.menus.MainMenuState());
    }
}