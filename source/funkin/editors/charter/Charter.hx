package funkin.editors.charter;

import flixel.math.FlxPoint;
import funkin.editors.charter.CharterBackdrop.CharterBackdropDummy;
import funkin.system.Conductor;
import funkin.chart.*;
import funkin.chart.ChartData;
import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import funkin.editors.ui.UIContextMenu.UIContextMenuOption;
import funkin.editors.ui.UIState;
import openfl.net.FileReference;

class Charter extends UIState {
    var __song:String;
    var __diff:String;

    var chart(get, null):ChartData;
    private function get_chart() 
        return PlayState.SONG;

    /**
     * CONFIG & UI (might make this customizable later)
     */
    public var uiGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
    private var gridColor1:FlxColor = 0xFF272727; // white
    private var gridColor2:FlxColor = 0xFF545454; // gray

    public var topMenu:Array<UIContextMenuOption>;

    public var topMenuSpr:UITopMenu;
    public var gridBackdrop:CharterBackdrop;
    public var gridBackdropDummy:CharterBackdropDummy;

    /**
     * ACTUAL CHART DATA
     */
    public var strumLines:Array<ChartStrumLine> = [];
    public var notesGroup:FlxTypedGroup<CharterNote> = new FlxTypedGroup<CharterNote>();

    /**
     * CAMERAS
     */
    // camera for the chart itself so that it can be unzoomed/zoomed in again
    public var charterCamera:FlxCamera;
    // camera for the ui
    public var uiCamera:FlxCamera;
	// selection box for the ui
	public var selectionBox:UISliceSprite;

    public var selection:Array<CharterNote> = [];

    public function new(song:String, diff:String) {
        super();
        __song = song;
        __diff = diff;
    }

    public override function create() {
        super.create();

        topMenu = [
            {
                label: "File",
                childs: [
                    {
                        label: "New"
                    },
                    null,
                    {
                        label: "Exit",
                        onSelect: _file_exit
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
                        label: "Delete",
                        onSelect: _edit_delete
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

        trace('Entering Charter for song $__song with difficulty $__diff.');


        charterCamera = FlxG.camera;
        uiCamera = new FlxCamera();
        uiCamera.bgColor = 0;
        FlxG.cameras.add(uiCamera);

        
        gridBackdrop = new CharterBackdrop();

        add(gridBackdropDummy = new CharterBackdropDummy(gridBackdrop));

		selectionBox = new UISliceSprite(0, 0, 2, 2, 'editors/ui/selection');
		selectionBox.visible = false;
		selectionBox.scrollFactor.set(1, 1);
		selectionBox.incorporeal = true;

		selectionBox.cameras = notesGroup.cameras = gridBackdrop.cameras = [charterCamera];


        topMenuSpr = new UITopMenu(topMenu);
        topMenuSpr.cameras = uiGroup.cameras = [uiCamera];


        // adds grid and notes so that they're ALWAYS behind the UI
        add(gridBackdrop);
        add(notesGroup);
		add(selectionBox);
        // add the ui group
        add(uiGroup);
        // add the top menu last OUT of the ui group so that it stays on top
        add(topMenuSpr);
        
        loadSong();
    }

    public function loadSong() {
        CoolUtil.loadSong(__song, __diff, false, false);

        Conductor.setupSong(PlayState.SONG);
        
        for(strID=>strL in PlayState.SONG.strumLines) {
            for(note in strL.notes) {
                var n = new CharterNote();
                n.updatePos(Conductor.getStepForTime(note.time), (strID * 4) + note.id, note.sLen, note.type);
                notesGroup.add(n);
            }
        }
    }

	/**
	 * NOTE AND CHARTER GRID LOGIC HERE
	 */
	#if REGION
	var selectionBoxEnabled:Bool = false;
	var dragStartPos:FlxPoint = new FlxPoint();

	public function updateNoteLogic(elapsed:Float) {
		notesGroup.forEach(function(n) {
            n.selected = false;
            if (n.hovered && !selectionBoxEnabled) {
                if (FlxG.mouse.justReleased) {
                    if (FlxG.keys.pressed.CONTROL)
                        selection.push(n);
                    else
                        selection = [n];
                }
                if (FlxG.mouse.justReleasedRight) {
                    if (!selection.contains(n))
                        selection = [n];
                    openContextMenu(topMenu[1].childs);
                }
            }
        });
        for(n in selection)
            n.selected = true;

        if (gridBackdropDummy.hovered || (selectionBoxEnabled && gridBackdropDummy.hoveredByChild)) {
			var mousePos = FlxG.mouse.getWorldPosition(charterCamera);
			if (FlxG.mouse.justPressed) {
				selectionBoxEnabled = false;
				FlxG.mouse.getWorldPosition(charterCamera, dragStartPos);
			}
			if (FlxG.mouse.pressed) {
				if (Math.abs(mousePos.x - dragStartPos.x) > 20 || Math.abs(mousePos.y - dragStartPos.y) > 20) {
					selectionBoxEnabled = true;
				}
				if (selectionBoxEnabled) {
					selectionBox.x = Math.min(mousePos.x, dragStartPos.x);
					selectionBox.y = Math.min(mousePos.y, dragStartPos.y);
					selectionBox.bWidth = Std.int(Math.abs(mousePos.x - dragStartPos.x));
					selectionBox.bHeight = Std.int(Math.abs(mousePos.y - dragStartPos.y));
				}
			}
			if (FlxG.mouse.justReleased) {
				if (selectionBoxEnabled) {
					var minX = Std.int(Math.round(selectionBox.x / 40));
					var minY = Math.round(selectionBox.y / 40) - 1;
					var maxX = Std.int(Math.round((selectionBox.x + selectionBox.bWidth) / 40));
					var maxY = Math.round((selectionBox.y + selectionBox.bHeight) / 40);

					selection = [];
					notesGroup.forEach(function(n) {
						if (n.id >= minX && n.id <= maxX && n.step >= minY && n.step <= maxY)
							selection.push(n);
					});

					selectionBoxEnabled = false;
				} else {
					// place note
					var note = new CharterNote();
					note.updatePos(FlxG.keys.pressed.SHIFT ? (mousePos.y / 40) : Std.int(mousePos.y / 40), Std.int(mousePos.x / 40), 0, 0);
					notesGroup.add(note);
					selection = [note];
				}
			}
			if (FlxG.mouse.justReleasedRight)
				openContextMenu(topMenu[2].childs);
		}
		selectionBox.visible = selectionBoxEnabled;
	}
	#end
    public override function update(elapsed:Float) {
        // TODO: do optimization like NoteGroup
		updateNoteLogic(elapsed);
        

        super.update(elapsed);

        gridBackdrop.strumlinesAmount = 3;

        // TODO: canTypeText in case an ui input element is focused
        if (true) {
            if (controls.LEFT)
                FlxG.camera.scroll.x -= 250 * elapsed;
            if (controls.RIGHT)
                FlxG.camera.scroll.x += 250 * elapsed;
            if (controls.UP)
                FlxG.camera.scroll.y -= 250 * elapsed;
            if (controls.DOWN)
                FlxG.camera.scroll.y += 250 * elapsed;

            if (FlxG.keys.justPressed.DELETE)
                _edit_delete();
        }
    }

    public function deleteNote(note:CharterNote):CharterNote {
        notesGroup.remove(note, true);
        note.kill();
        note.destroy();
        return null;
    }


    // TOP MENU OPTIONS
    #if REGION
    function _file_exit() {
        FlxG.switchState(new CharterSelection());
    }
    function _edit_delete() {
        if (selection == null) return;
        for(s in selection)
            deleteNote(s);
    }
    #end
}