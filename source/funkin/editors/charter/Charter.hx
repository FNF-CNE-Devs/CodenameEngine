package funkin.editors.charter;

import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.util.FlxSort;
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

	public static var instance(get, null):Charter;

	private static inline function get_instance()
		return FlxG.state is Charter ? cast FlxG.state : null;

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
	public var conductorFollowerSpr:FlxSprite;

	public var hitsound:FlxSound;
	public var metronome:FlxSound;

	public var vocals:FlxSound;

	/**
	 * ACTUAL CHART DATA
	 */
	public var strumLines:Array<CharterStrumline> = [];
	public var notesGroup:CharterNoteGroup = new CharterNoteGroup();

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

	public var undoList:Array<CharterChange> = [];
	public var redoList:Array<CharterChange> = [];

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
						label: "Undo",
						keybind: [CONTROL, Z],
						onSelect: _edit_undo
					},
					{
						label: "Redo",
						keybinds: [[CONTROL, Y], [CONTROL, SHIFT, Z]],
						onSelect: _edit_redo
					},
					null,
					{
						label: "Cut",
						keybind: [CONTROL, X]
					},
					{
						label: "Copy",
						keybind: [CONTROL, C]
					},
					{
						label: "Paste",
						keybind: [CONTROL, V]
					},
					null,
					{
						label: "Delete",
						keybind: [DELETE],
						onSelect: _edit_delete
					}
				]
			},
			{
				label: "Chart",
				childs: [
					{
						label: "Playtest",
						keybind: [ENTER]
					},
					{
						label: "Playtest here",
						keybind: [SHIFT, ENTER]
					},
					null,
					{
						label: "Playtest as opponent",
						keybind: [CONTROL, ENTER]
					},
					{
						label: "Playtest as opponent here",
						keybind: [CONTROL, SHIFT, ENTER]
					},
					null,
					{
						label: "Zoom in",
						keybind: [CONTROL, NUMPADPLUS],
						onSelect: _chart_zoomin
					},
					{
						label: "Zoom out",
						keybind: [CONTROL, NUMPADMINUS],
						onSelect: _chart_zoomout
					},
					{
						label: "Reset zoom",
						keybind: [CONTROL, NUMPADZERO],
						onSelect: _chart_zoomreset
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
						label: "Play/Pause",
						keybind: [SPACE],
						onSelect: _playback_play
					},
					null,
					{
						label: "Go back a section",
						keybind: [A],
						onSelect: _playback_back
					},
					{
						label: "Go forward a section",
						keybind: [D],
						onSelect: _playback_forward
					},
					null,
					{
						label: "Go back to the start",
						keybind: [HOME],
						onSelect: _playback_start
					},
					{
						label: "Go to the end",
						keybind: [END],
						onSelect: _playback_end
					},
					null,
					{
						label: "Metronome",
						onSelect: _playback_metronome
					},
					{
						label: "Visual metronome"
					},
					null,
					{
						label: "Mute instrumental",
						onSelect: _playback_muteinst
					},
					{
						label: "Mute voices",
						onSelect: _playback_mutevoices
					}
				]
			}
		];


		hitsound = FlxG.sound.load(Paths.sound('editors/charter/hitsound'));
		metronome = FlxG.sound.load(Paths.sound('editors/charter/metronome'));

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

		conductorFollowerSpr = new FlxSprite(0, 0).makeGraphic(1, 1, -1);
		conductorFollowerSpr.scale.set(gridBackdrop.strumlinesAmount * 4 * 40, 4);
		conductorFollowerSpr.updateHitbox();

		conductorFollowerSpr.cameras = selectionBox.cameras = notesGroup.cameras = gridBackdrop.cameras = [charterCamera];


		topMenuSpr = new UITopMenu(topMenu);
		topMenuSpr.cameras = uiGroup.cameras = [uiCamera];


		// adds grid and notes so that they're ALWAYS behind the UI
		add(gridBackdrop);
		add(notesGroup);
		add(conductorFollowerSpr);
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

		FlxG.sound.music = FlxG.sound.load(Paths.inst(__song, __diff));
		vocals = FlxG.sound.load(Paths.voices(__song, __diff));
		
		for(strID=>strL in PlayState.SONG.strumLines) {
			for(note in strL.notes) {
				var n = new CharterNote();
				n.updatePos(Conductor.getStepForTime(note.time), (strID * 4) + note.id, note.sLen, note.type);
				notesGroup.add(n);
			}

			strumLines.push({
				strumLine: strL,
				hitsounds: true
			});
		}
	}

	public override function beatHit(curBeat:Int) {
		super.beatHit(curBeat);
		if (FlxG.sound.music.playing) {
			if (Options.charterMetronomeEnabled)
				metronome.replay();
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
					else if (FlxG.keys.pressed.SHIFT)
						selection.remove(n);
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
					var minX = Std.int(selectionBox.x / 40);
					var minY = Std.int(selectionBox.y / 40);
					var maxX = Std.int(Math.ceil((selectionBox.x + selectionBox.bWidth) / 40));
					var maxY = Math.ceil((selectionBox.y + selectionBox.bHeight) / 40);

					if (FlxG.keys.pressed.SHIFT) {
						notesGroup.forEach(function(n) {
							if (n.id >= minX && n.id < maxX && n.step >= minY && n.step < maxY && selection.contains(n))
								selection.remove(n);
						});
					} else if (FlxG.keys.pressed.CONTROL) {
						notesGroup.forEach(function(n) {
							if (n.id >= minX && n.id < maxX && n.step >= minY && n.step < maxY && !selection.contains(n))
								selection.push(n);
						});
					} else {
						selection = [];
						notesGroup.forEach(function(n) {
							if (n.id >= minX && n.id < maxX && n.step >= minY && n.step < maxY)
								selection.push(n);
						});
					}

					selectionBoxEnabled = false;
				} else if (selection.length > 0) {
					selection = [];
				} else {
					// place note
					var id = Std.int(mousePos.x / 40);
					if (id >= 0 && id < 4 * gridBackdrop.strumlinesAmount) {
						var note = new CharterNote();
						note.updatePos(FlxG.keys.pressed.SHIFT ? (mousePos.y / 40) : Std.int(mousePos.y / 40), id, 0, 0);
						notesGroup.add(note);
						addToUndo(CPlaceNote(note));
					}
				}
			}
			if (FlxG.mouse.justReleasedRight)
				openContextMenu(topMenu[2].childs);
		}
		selectionBox.visible = selectionBoxEnabled;
	}

	public function deleteNote(note:CharterNote):CharterNote {
		if (note == null) return note;

		notesGroup.remove(note, true);
		note.kill();
		addToUndo(CDeleteNotes([note]));
		return null;
	}

	public function deleteNotes(notes:Array<CharterNote>) {
		if (notes.length <= 0) return [];

		for(note in notes) {
			notesGroup.remove(note, true);
			note.kill();
		}
		addToUndo(CDeleteNotes(notes));
		return [];
	}

	// UNDO/REDO LOGIC
	#if REGION
	public inline function addToUndo(c:CharterChange) {
		redoList = [];
		undoList.insert(0, c);
		while(undoList.length > Options.maxUndos)
			undoList.pop();
	}
	
	function _edit_undo(_) {
		selection = [];
		var v = undoList.shift();
		switch(v) {
			case null:
				// do nothing
			case CCreateNotes(notes):
				for(n in notes) {
					notesGroup.remove(n, true);
					n.kill();
					selection.remove(n);
				}
			case CDeleteNotes(notes):
				for(n in notes) {
					notesGroup.add(n);
					n.revive();
				}
				sortNotes();
			case CPlaceNote(note):
				notesGroup.remove(note, true);
				note.kill();
				selection.remove(note);
		}
		if (v != null)
			redoList.insert(0, v);
	}

	function _playback_play(_) {
		if (FlxG.sound.music.playing) {
			FlxG.sound.music.pause();
			vocals.pause();
		} else {
			vocals.time = FlxG.sound.music.time = Conductor.songPosition;
			FlxG.sound.music.play();
			vocals.play();
		}
	}

	function _edit_redo(_) {
		selection = [];
		var v = redoList.shift();
		switch(v) {
			case null:
				// do nothing
			case CCreateNotes(notes):
				for(n in notes) {
					notesGroup.add(n);
					n.revive();
				}
			case CDeleteNotes(notes):
				for(n in notes) {
					notesGroup.remove(n, true);
					n.kill();
				}
			case CPlaceNote(note):
				notesGroup.add(note);
				note.revive();
		}
		if (v != null)
			undoList.insert(0, v);
	}

	function _playback_metronome(t) {
		t.icon = (Options.charterMetronomeEnabled = !Options.charterMetronomeEnabled) ? 1 : 0;
	}
	function _playback_muteinst(t) {
		FlxG.sound.music.volume = FlxG.sound.music.volume > 0 ? 0 : 1;
		t.icon = 1 - Std.int(Math.ceil(FlxG.sound.music.volume));
	}
	function _playback_mutevoices(t) {
		vocals.volume = vocals.volume > 0 ? 0 : 1;
		t.icon = 1 - Std.int(Math.ceil(vocals.volume));
	}
	#end

	public inline function sortNotes()
		notesGroup.sort((i, c1, c2) -> FlxSort.byValues(i, c1.step, c2.step), FlxSort.ASCENDING);
	#end

	var __crochet:Float;
	public override function update(elapsed:Float) {
		// TODO: do optimization like NoteGroup
		updateNoteLogic(elapsed);

		super.update(elapsed);

		if (gridBackdrop.strumlinesAmount != (gridBackdrop.strumlinesAmount = strumLines.length)) {
			conductorFollowerSpr.scale.set(gridBackdrop.strumlinesAmount * 4 * 40, 4);
			conductorFollowerSpr.updateHitbox();
		}

		// TODO: canTypeText in case an ui input element is focused
		if (true) {
			__crochet = ((60 / Conductor.bpm) * 1000);

			UIUtil.processShortcuts(topMenu);

			if (FlxG.keys.pressed.CONTROL) {
				if (FlxG.mouse.wheel != 0) {
					zoom += 0.25 * FlxG.mouse.wheel;
					__camZoom = Math.pow(2, zoom);
				}
			} else {
				if (!FlxG.sound.music.playing) {
					Conductor.songPosition -= __crochet * FlxG.mouse.wheel;
				}
			}
		}

		Conductor.songPosition = FlxMath.bound(Conductor.songPosition, 0, FlxG.sound.music.length);

		if (FlxG.sound.music.playing) {
			conductorFollowerSpr.y = curStepFloat * 40;
		} else {
			conductorFollowerSpr.y = lerp(conductorFollowerSpr.y, curStepFloat * 40, 1/3);
		}
		charterCamera.scroll.set(conductorFollowerSpr.x + ((conductorFollowerSpr.scale.x - FlxG.width) / 2), conductorFollowerSpr.y - (FlxG.height * 0.5));
		if (charterCamera.zoom != (charterCamera.zoom = lerp(charterCamera.zoom, __camZoom, 0.125))) {

		}
	}

	var zoom:Float = 0;
	var __camZoom:Float = 1;

	// TOP MENU OPTIONS
	#if REGION
	function _file_exit(_) {
		FlxG.switchState(new CharterSelection());
	}
	function _edit_delete(_) {
		if (selection == null) return;
		selection = deleteNotes(selection);
	}
	function _playback_back(_) {
		if (FlxG.sound.music.playing) return;
		Conductor.songPosition -= Conductor.beatsPerMesure * __crochet;
	}
	function _playback_forward(_) {
		if (FlxG.sound.music.playing) return;
		Conductor.songPosition += Conductor.beatsPerMesure * __crochet;
	}
	function _playback_start(_) {
		if (FlxG.sound.music.playing) return;
		Conductor.songPosition = 0;
	}
	function _playback_end(_) {
		if (FlxG.sound.music.playing) return;
		Conductor.songPosition = FlxG.sound.music.length;
	}
	function _chart_zoomin(_) {
		zoom += 0.25;
		__camZoom = Math.pow(2, zoom);
	}
	function _chart_zoomout(_) {
		zoom -= 0.25;
		__camZoom = Math.pow(2, zoom);
	}
	function _chart_zoomreset(_) {
		zoom = 0;
		__camZoom = Math.pow(2, zoom);
	}
	#end
	
	public inline function hitsoundsEnabled(id:Int)
		return strumLines[Std.int(id / 4)] != null && strumLines[Std.int(id / 4)].hitsounds;
}

enum CharterChange {
	CPlaceNote(note:CharterNote);
	CCreateNotes(notes:Array<CharterNote>);
	CDeleteNotes(notes:Array<CharterNote>);
}

typedef CharterStrumline = {
	var strumLine:ChartStrumLine;
	var hitsounds:Bool;
}