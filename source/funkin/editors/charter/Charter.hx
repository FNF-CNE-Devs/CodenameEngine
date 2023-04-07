package funkin.editors.charter;

import flixel.input.keyboard.FlxKey;
import flixel.sound.FlxSound;
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
	var __reload:Bool;

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
	public var beatSeparator:FlxBackdrop;
	public var sectionSeparator:FlxBackdrop;
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

	public var clipboard:Array<CharterCopyboardObject> = [];

	public function new(song:String, diff:String, reload:Bool = true) {
		super();
		__song = song;
		__diff = diff;
		__reload = reload;
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
						keybind: [CONTROL, C],
						onSelect: _edit_copy
					},
					{
						label: "Paste",
						keybind: [CONTROL, V],
						onSelect: _edit_paste
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
						keybind: [ENTER],
						onSelect: _chart_playtest
					},
					{
						label: "Playtest here",
						keybind: [SHIFT, ENTER],
						onSelect: _chart_playtest_here
					},
					null,
					{
						label: "Playtest as opponent",
						keybind: [CONTROL, ENTER],
						onSelect: _chart_playtest_opponent
					},
					{
						label: "Playtest as opponent here",
						keybind: [CONTROL, SHIFT, ENTER],
						onSelect: _chart_playtest_opponent_here
					},
					null,
					{
						label: "Edit metadata information"
					}
				]
			},
			{
				label: "View",
				childs: [
					{
						label: "Zoom in",
						keybind: [CONTROL, NUMPADPLUS],
						onSelect: _view_zoomin
					},
					{
						label: "Zoom out",
						keybind: [CONTROL, NUMPADMINUS],
						onSelect: _view_zoomout
					},
					{
						label: "Reset zoom",
						keybind: [CONTROL, NUMPADZERO],
						onSelect: _view_zoomreset
					},
					null,
					{
						label: 'Show Sections Separator',
						onSelect: _view_showsectionseparator,
						icon: Options.charterShowSections ? 1 : 0
					},
					{
						label: 'Show Beats Separator',
						onSelect: _view_showbeatseparator,
						icon: Options.charterShowBeats ? 1 : 0
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
						onSelect: _playback_metronome,
						icon: Options.charterMetronomeEnabled ? 1 : 0
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
		sectionSeparator = new FlxBackdrop(null, Y, 0, 0);
		sectionSeparator.x = -20;
		sectionSeparator.y = -2;
		sectionSeparator.visible = Options.charterShowSections;
		beatSeparator = new FlxBackdrop(null, Y, 0, 0);
		beatSeparator.x = -10;
		beatSeparator.y = -1;
		sectionSeparator.visible = Options.charterShowBeats;
		for(sep in [sectionSeparator, beatSeparator]) {
			sep.makeGraphic(1, 1, -1);
			sep.alpha = 0.5;
			sep.scrollFactor.set(1, 1);
			sep.cameras = [charterCamera];
		}


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
		add(sectionSeparator);
		add(beatSeparator);
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
		if (__reload)
			CoolUtil.loadSong(__song, __diff, false, false);

		Conductor.setupSong(PlayState.SONG);

		FlxG.sound.setMusic(FlxG.sound.load(Paths.inst(__song, __diff)));
		vocals = FlxG.sound.load(Paths.voices(__song, __diff));
		vocals.group = FlxG.sound.defaultMusicGroup;

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
	#end

	public inline function sortNotes()
		notesGroup.sort((i, c1, c2) -> FlxSort.byValues(i, c1.step, c2.step), FlxSort.ASCENDING);
	#end

	var __crochet:Float;
	public override function update(elapsed:Float) {
		updateNoteLogic(elapsed);

		super.update(elapsed);

		if (gridBackdrop.strumlinesAmount != (gridBackdrop.strumlinesAmount = strumLines.length)) {
			conductorFollowerSpr.scale.set(gridBackdrop.strumlinesAmount * 4 * 40, 4);
			conductorFollowerSpr.updateHitbox();

			sectionSeparator.scale.set((gridBackdrop.strumlinesAmount * 4 * 40) + 20, 4);
			sectionSeparator.updateHitbox();

			beatSeparator.scale.set((gridBackdrop.strumlinesAmount * 4 * 40) + 10, 2);
			beatSeparator.updateHitbox();
		}
		sectionSeparator.spacing.y = (10 * Conductor.beatsPerMesure * Conductor.stepsPerBeat) - 1;
		beatSeparator.spacing.y = (20 * Conductor.stepsPerBeat) - 1;

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
	function _edit_copy(_) {
		var minStep:Float = selection[0].step;
		for(s in selection)
			if (s.step < minStep)
				minStep = s.step;

		clipboard = [for(s in selection) CNote(s.step - minStep, s.id, s.susLength, s.type)];
	}
	function _edit_paste(_) {
		if (clipboard.length <= 0) return;

		var minStep = curStep;
		var notes:Array<CharterNote> = [];
		for(c in clipboard) {
			switch(c) {
				case CNote(step, id, sLen, type):
					var note = new CharterNote();
					note.updatePos(minStep + step, id, sLen, type);
					notes.push(note);
					notesGroup.add(note);
			}
		}
		selection = notes;
		addToUndo(CCreateNotes(notes.copy()));

	}
	function _edit_delete(_) {
		if (selection == null) return;
		selection = deleteNotes(selection);
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

	inline function _chart_playtest(_)
		playtestChart(0, false);
	inline function _chart_playtest_here(_)
		playtestChart(Conductor.songPosition, false);
	inline function _chart_playtest_opponent(_)
		playtestChart(0, true);
	inline function _chart_playtest_opponent_here(_)
		playtestChart(Conductor.songPosition, true);

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
	function _view_zoomin(_) {
		zoom += 0.25;
		__camZoom = Math.pow(2, zoom);
	}
	function _view_zoomout(_) {
		zoom -= 0.25;
		__camZoom = Math.pow(2, zoom);
	}
	function _view_zoomreset(_) {
		zoom = 0;
		__camZoom = Math.pow(2, zoom);
	}
	function _view_showsectionseparator(t) {
		t.icon = (Options.charterShowSections = !Options.charterShowSections) ? 1 : 0;
		sectionSeparator.visible = Options.charterShowSections;
	}
	function _view_showbeatseparator(t) {
		t.icon = (Options.charterShowBeats = !Options.charterShowBeats) ? 1 : 0;
		beatSeparator.visible = Options.charterShowBeats;
	}
	#end

	public function playtestChart(time:Float = 0, opponentMode = false) {
		buildChart();
		PlayState.opponentMode = opponentMode;
		PlayState.chartingMode = true;
		FlxG.switchState(new PlayState());
	}

	public function buildChart() {
		PlayState.SONG.strumLines = [];
		for(s in strumLines) {
			s.strumLine.notes = [];
			PlayState.SONG.strumLines.push(s.strumLine);
		}
		for(n in notesGroup.members) {
			var strLineID = Std.int(n.id / 4);
			if (PlayState.SONG.strumLines[strLineID] != null) {
				PlayState.SONG.strumLines[strLineID].notes.push({
					type: n.type,
					time: Conductor.getTimeForStep(n.step),
					sLen: n.susLength,
					id: n.id % 4
				});
			}
		}
	}

	public inline function hitsoundsEnabled(id:Int)
		return strumLines[Std.int(id / 4)] != null && strumLines[Std.int(id / 4)].hitsounds;
}

enum CharterChange {
	CPlaceNote(note:CharterNote);
	CCreateNotes(notes:Array<CharterNote>);
	CDeleteNotes(notes:Array<CharterNote>);
}

enum CharterCopyboardObject {
	CNote(step:Float, id:Int, susLength:Float, type:Int);
}

typedef CharterStrumline = {
	var strumLine:ChartStrumLine;
	var hitsounds:Bool;
}