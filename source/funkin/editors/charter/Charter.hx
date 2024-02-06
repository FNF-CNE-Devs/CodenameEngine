package funkin.editors.charter;

import funkin.editors.ui.UIContextMenu.UIContextMenuOptionSpr;
import funkin.editors.ui.UITopMenu.UITopMenuButton;
import funkin.editors.charter.CharterStrumline;
import funkin.editors.charter.CharterBackdropGroup.EventBackdrop;
import funkin.backend.system.framerate.Framerate;
import haxe.Json;
import flixel.input.keyboard.FlxKey;
import flixel.sound.FlxSound;
import flixel.util.FlxSort;
import flixel.math.FlxPoint;
import funkin.editors.charter.CharterBackdropGroup.CharterBackdropDummy;
import funkin.backend.system.Conductor;
import funkin.backend.chart.*;
import funkin.backend.chart.ChartData;
import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import funkin.editors.ui.UIContextMenu.UIContextMenuOption;
import funkin.editors.ui.UIState;
import openfl.net.FileReference;

class Charter extends UIState {
	public static var __song:String;
	static var __diff:String;
	static var __reload:Bool;

	var chart(get, null):ChartData;
	private function get_chart()
		return PlayState.SONG;

	public static var instance(get, null):Charter;

	private static inline function get_instance()
		return FlxG.state is Charter ? cast FlxG.state : null;

	public var charterBG:FunkinSprite;
	public var uiGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	public var topMenu:Array<UIContextMenuOption>;
	@:noCompletion private var playbackIndex:Int = 7;
	@:noCompletion private var snapIndex:Int = 6;
	@:noCompletion private var noteIndex:Int = 5;

	public var scrollBar:UIScrollBar;
	public var songPosInfo:UIText;

	public var quantButtons:Array<CharterQuantButton> = [];
	public var playBackSlider:UISlider;

	public var topMenuSpr:UITopMenu;
	public var gridBackdrops:CharterBackdropGroup;
	public var eventsBackdrop:EventBackdrop;
	public var addEventSpr:CharterEventAdd;

	public var gridBackdropDummy:CharterBackdropDummy;
	public var noteHoverer:CharterNote;

	public var strumlineInfoBG:FlxSprite;
	public var strumlineAddButton:CharterStrumlineButton;
	public var strumlineLockButton:CharterStrumlineButton;

	public var hitsound:FlxSound;
	public var metronome:FlxSound;

	public var vocals:FlxSound;

	public var quant:Int = 16;
	public var quants:Array<Int> = [4, 8, 12, 16, 20, 24, 32, 48, 64, 192]; // different quants

	public var noteType:Int = 0;
	public var noteTypes:Array<String> = [];
	public var noteTypeText:UIText;

	public var strumLines:CharterStrumLineGroup = new CharterStrumLineGroup();
	public var notesGroup:CharterNoteGroup = new CharterNoteGroup();
	public var eventsGroup:CharterEventGroup = new CharterEventGroup();

	public var charterCamera:FlxCamera;
	public var uiCamera:FlxCamera;
	public var selectionBox:UISliceSprite;

	public static var selection:Selection;

	public static var playtestInfo:PlaytestInfo;
	public static var undos:UndoList<CharterChange>;

	public static var clipboard:Array<CharterCopyboardObject> = [];

	public function new(song:String, diff:String, reload:Bool = true) {
		super();
		if (song != null) {
			__song = song;
			__diff = diff;
			__reload = reload;
		}
	}

	public override function create() {
		super.create();

		WindowUtils.endfix = " (Chart Editor)";
		SaveWarning.selectionClass = CharterSelection;
		SaveWarning.saveFunc = () -> {_file_save(null);};
		
		topMenu = [
			{
				label: "File",
				childs: [
					{
						label: "New"
					},
					null,
					{
						label: "Save",
						keybind: [CONTROL, S],
						onSelect: _file_save,
					},
					{
						label: "Save As...",
						keybind: [CONTROL, SHIFT, S],
						onSelect: _file_saveas,
					},
					null,
					{
						label: "Save Meta",
						keybind: [CONTROL, ALT, S],
						onSelect: _file_meta_save,
					},
					{
						label: "Save Meta As...",
						keybind: [CONTROL, ALT ,SHIFT, S],
						onSelect: _file_meta_saveas,
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
						label: "Cut",
						keybind: [CONTROL, X],
						onSelect: _edit_cut
					},
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
						label: 'Enable scripts during playtesting',
						onSelect: _chart_enablescripts,
						icon: Options.charterEnablePlaytestScripts ? 1 : 0
					},
					null,
					{
						label: "Edit chart data",
						color: 0xFF959829, icon: 4,
						onCreate: function (button:UIContextMenuOptionSpr) {button.label.offset.x = button.icon.offset.x = -2;},
						onSelect: chart_edit_data
					},
					{
						label: "Edit metadata information",
						color: 0xFF959829, icon: 4,
						onCreate: function (button:UIContextMenuOptionSpr) {button.label.offset.x = button.icon.offset.x = -2;},
						onSelect: chart_edit_metadata
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
						onSelect: _view_showeventSecSeparator,
						icon: Options.charterShowSections ? 1 : 0
					},
					{
						label: 'Show Beats Separator',
						onSelect: _view_showeventBeatSeparator,
						icon: Options.charterShowBeats ? 1 : 0
					}
				]
			},
			{
				label: "Song",
				childs: [
					{
						label: "Go back to the start",
						keybind: [HOME],
						onSelect: _song_start
					},
					{
						label: "Go to the end",
						keybind: [END],
						onSelect: _song_end
					},
					null,
					{
						label: "Mute instrumental",
						onSelect: _song_muteinst
					},
					{
						label: "Mute voices",
						onSelect: _song_mutevoices
					}
				]
			},
			{
				label: "Note >",
				childs: buildNoteTypesUI()
			},
			{
				label: "Snap >",
				childs: buildSnapsUI()
			},
			{
				label: "Playback >",
				childs: [
					{
						label: "Play/Pause",
						keybind: [SPACE],
						onSelect: _playback_play
					},
					null,
					{
						label: "↑ Speed 25%",
						onSelect: _playback_speed_raise
					},
					{
						label: "Reset Speed",
						onSelect: _playback_speed_reset
					},
					{
						label: "↓ Speed 25%",
						onSelect: _playback_speed_lower
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
						label: "Metronome",
						onSelect: _playback_metronome,
						icon: Options.charterMetronomeEnabled ? 1 : 0
					},
					{
						label: "Visual metronome"
					},
				]
			}
		];

		hitsound = FlxG.sound.load(Paths.sound('editors/charter/hitsound'));
		metronome = FlxG.sound.load(Paths.sound('editors/charter/metronome'));

		charterCamera = FlxG.camera;
		uiCamera = new FlxCamera();
		uiCamera.bgColor = 0;
		FlxG.cameras.add(uiCamera);

		charterBG = new FunkinSprite(0, 0, Paths.image('menus/menuDesat'));
		charterBG.color = 0xFF181818;
		charterBG.cameras = [charterCamera];
		charterBG.screenCenter();
		charterBG.scrollFactor.set();
		add(charterBG);

		gridBackdrops = new CharterBackdropGroup(strumLines);
		gridBackdrops.notesGroup = this.notesGroup;

		eventsBackdrop = new EventBackdrop();
		eventsBackdrop.x = -eventsBackdrop.width;
		eventsBackdrop.cameras = [charterCamera];
		eventsGroup.eventsBackdrop = eventsBackdrop;

		add(gridBackdropDummy = new CharterBackdropDummy(gridBackdrops));
		selectionBox = new UISliceSprite(0, 0, 2, 2, 'editors/ui/selection');
		selectionBox.visible = false;
		selectionBox.scrollFactor.set(1, 1);
		selectionBox.incorporeal = true;

		noteHoverer = new CharterNote();
		noteHoverer.snappedToStrumline = noteHoverer.selectable = noteHoverer.autoAlpha = false;
		@:privateAccess noteHoverer.__animSpeed = 1.25; noteHoverer.typeText.visible = false;
		noteHoverer.alpha = 0; // FUCK YOU NOTE HOVERER >:(((

		selectionBox.cameras = notesGroup.cameras = gridBackdrops.cameras = noteHoverer.cameras = [charterCamera];

		topMenuSpr = new UITopMenu(topMenu);
		topMenuSpr.cameras = uiGroup.cameras = [uiCamera];

		noteTypeText = new UIText(0, 0, 0, "(0) Default Note");
		noteTypeText.cameras = [uiCamera];

		scrollBar = new UIScrollBar(FlxG.width - 20, topMenuSpr.bHeight, 1000, 0, 100);
		scrollBar.cameras = [uiCamera];
		scrollBar.onChange = function(v) {
			if (!FlxG.sound.music.playing)
				Conductor.songPosition = Conductor.getTimeForStep(v) + Conductor.songOffset;
		};
		uiGroup.add(scrollBar);

		songPosInfo = new UIText(FlxG.width - 30 - 400, scrollBar.y + 10, 400, "00:00\nBeat: 0\nStep: 0\nMeasure: 0\nBPM: 0\nTime Signature: 4/4");
		songPosInfo.alignment = RIGHT; songPosInfo.optimized = true;
		uiGroup.add(songPosInfo);

		playBackSlider = new UISlider(FlxG.width - 160 - 26 - 20, (23/2) - (12/2), 160, 1, [{start: 0.25, end: 1, size: 0.5}, {start: 1, end: 2, size: 0.5}], true);
		playBackSlider.onChange = function (v) {
			FlxG.sound.music.pitch = vocals.pitch = v;
			for (strumLine in strumLines.members) strumLine.vocals.pitch = v;
		};
		uiGroup.add(playBackSlider);

		quants.reverse();
		for (quant in quants) {
			var button:CharterQuantButton = new CharterQuantButton(0, 0, quant);
			button.onClick = () -> {setquant(button.quant);};
			quantButtons.push(cast uiGroup.add(button));
		}
		quants.reverse();

		strumlineInfoBG = new UISprite();
		strumlineInfoBG.loadGraphic(Paths.image('editors/charter/strumline-info-bg'));
		strumlineInfoBG.y = 23;
		strumlineInfoBG.scrollFactor.set();

		strumlineAddButton = new CharterStrumlineButton("editors/new", "Create New");
		strumlineAddButton.onClick = createStrumWithUI;
		strumlineAddButton.animationOnClick = false;
		strumlineAddButton.textColorLerp = 0.5;

		strumlineLockButton = new CharterStrumlineButton("editors/charter/lock-strumline", "Lock/Unlock");
		strumlineLockButton.onClick = function () {
			if (strumLines != null) {
				strumLines.draggable = !strumLines.draggable;
				strumlineLockButton.textTweenColor.color = strumLines.draggable ? 0xFF5C95CA : 0xFFE16565;
			}
		};

		strumlineAddButton.cameras = strumlineLockButton.cameras = [charterCamera];
		strumlineInfoBG.cameras = [charterCamera];
		strumLines.cameras = [charterCamera];

		addEventSpr = new CharterEventAdd();
		addEventSpr.x -= addEventSpr.bWidth;
		addEventSpr.cameras = [charterCamera];
		addEventSpr.alpha = 0;

		// adds grid and notes so that they're ALWAYS behind the UI
		add(gridBackdrops);
		add(eventsBackdrop);
		add(addEventSpr);
		add(eventsGroup);
		add(noteHoverer);
		add(notesGroup);
		add(selectionBox);
		add(strumlineInfoBG);
		add(strumlineLockButton);
		add(strumlineAddButton);
		add(strumLines);
		// add the top menu last OUT of the ui group so that it stays on top
		add(topMenuSpr);
		add(noteTypeText);
		// add the ui group
		add(uiGroup);

		loadSong();

		if(Framerate.isLoaded) {
			Framerate.fpsCounter.alpha = 0.4;
			Framerate.memoryCounter.alpha = 0.4;
			Framerate.codenameBuildField.alpha = 0.4;
		}
		updateDisplaySprites();
	}

	override function destroy() {
		__updatePlaytestInfo();

		if(Framerate.isLoaded) {
			Framerate.fpsCounter.alpha = 1;
			Framerate.memoryCounter.alpha = 1;
			Framerate.codenameBuildField.alpha = 1;
		}
		super.destroy();
	}

	public function loadSong() {
		if (__reload) {
			EventsData.reloadEvents();
			PlayState.loadSong(__song, __diff, false, false);
			__resetStatics();
		}
		Conductor.setupSong(PlayState.SONG);
		noteTypes = PlayState.SONG.noteTypes;

		FlxG.sound.setMusic(FlxG.sound.load(Paths.inst(__song, __diff)));
		vocals = FlxG.sound.load(Paths.voices(__song, __diff));
		vocals.group = FlxG.sound.defaultMusicGroup;

		gridBackdrops.createGrids(PlayState.SONG.strumLines.length);

		for(strL in PlayState.SONG.strumLines)
			createStrumline(strumLines.members.length, strL, false, false);
		
		// create notes
		notesGroup.autoSort = false;
		var noteCount:Int = 0;
		for (strL in PlayState.SONG.strumLines)
			for (note in strL.notes) noteCount++;
		notesGroup.preallocate(noteCount);

		var notesCreated:Int = 0;
		for (i => strL in PlayState.SONG.strumLines)
			for (note in strL.notes) {
				var n = new CharterNote();
				var t = Conductor.getStepForTime(note.time);
				n.updatePos(t, note.id, Conductor.getStepForTime(note.time + note.sLen) - t, note.type, strumLines.members[i]);
				notesGroup.members[notesCreated++] = n;
			}
		notesGroup.sortNotes();
		notesGroup.autoSort = true;

		// create events
		eventsGroup.autoSort = false;
		var __last:CharterEvent = null;
		var __lastTime:Float = Math.NaN;
		for(e in PlayState.SONG.events) {
			if (e == null) continue;
			if (__last != null && __lastTime == e.time) {
				__last.events.push(e);
			} else {
				__last = new CharterEvent(Conductor.getStepForTime(e.time), [e]);
				__lastTime = e.time;
				eventsGroup.add(__last);
			}
		}

		eventsGroup.sortEvents();
		eventsGroup.autoSort = true;

		for(e in eventsGroup.members)
			e.refreshEventIcons();


		buildNoteTypesUI();
		refreshBPMSensitive();

		// Cool shit :DD 
		__relinkSelection();
		__relinkUndos();
		__applyPlaytestInfo();
	}

	public var __endStep:Float = 0;
	public function refreshBPMSensitive() {
		// refreshes everything dependant on BPM, and BPM changes
		var length = FlxG.sound.music.getDefault(vocals).length;
		scrollBar.length = __endStep = Conductor.getStepForTime(length);

		gridBackdrops.bottomLimitY = Conductor.getStepForTime(length) * 40;
		eventsBackdrop.bottomSeparator.y = gridBackdrops.bottomLimitY-2;
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
	var gridActionType:CharterGridActionType = NONE;
	var dragStartPos:FlxPoint = new FlxPoint();
	var selectionDragging:Bool = false;

	public function updateNoteLogic(elapsed:Float) {
		for (group in [notesGroup, eventsGroup]) {
			cast(group, FlxTypedGroup<Dynamic>).forEach(function(n) {
				n.selected = false;
				if (n.hovered && gridActionType == NONE) {
					if (FlxG.mouse.justReleased) {
						if (FlxG.keys.pressed.CONTROL)
							selection.push(cast n);
						else if (FlxG.keys.pressed.SHIFT)
							selection.remove(cast n);
						else
							selection = [cast n];
					}
					if (FlxG.mouse.justReleasedRight) {
						var mousePos = FlxG.mouse.getScreenPosition(uiCamera);
						if (!selection.contains(cast n))
							selection = [cast n];
						closeCurrentContextMenu();
						openContextMenu(topMenu[1].childs, null, mousePos.x, mousePos.y);
						mousePos.put();
					}
				}
			});
		}
		for(n in selection) n.selected = true;

		/**
		 * NOTE DRAG HANDLING
		 */
		var mousePos = FlxG.mouse.getWorldPosition(charterCamera);
		if (!gridBackdropDummy.hoveredByChild && !FlxG.mouse.pressed)
			gridActionType = NONE;
		selectionBox.visible = false;
		switch(gridActionType) {
			case BOX:
				if (gridBackdropDummy.hoveredByChild) {
					selectionBox.visible = true;
					if (FlxG.mouse.pressed) {
						selectionBox.x = Math.min(mousePos.x, dragStartPos.x);
						selectionBox.y = Math.min(mousePos.y, dragStartPos.y);
						selectionBox.bWidth = Std.int(Math.abs(mousePos.x - dragStartPos.x));
						selectionBox.bHeight = Std.int(Math.abs(mousePos.y - dragStartPos.y));
					} else {
						if (FlxG.keys.pressed.SHIFT) {
							for (group in [notesGroup, eventsGroup])
								for(n in cast(group, FlxTypedGroup<Dynamic>))
									if (n.handleSelection(selectionBox) && selection.contains(n))
										selection.remove(n);
						} else if (FlxG.keys.pressed.CONTROL) {
							for (group in [notesGroup, eventsGroup])
								for(n in cast(group, FlxTypedGroup<Dynamic>))
									if (n.handleSelection(selectionBox) && !selection.contains(n))
										selection.push(n);
						} else {
							selection = [];
							for (group in [notesGroup, eventsGroup])
								for(n in cast(group, FlxTypedGroup<Dynamic>))
									if (n.handleSelection(selectionBox))
										selection.push(n);
						}
						gridActionType = NONE;
					}
				}
			case INVALID_DRAG:
				// do nothing, locked
				if (!FlxG.mouse.pressed)
					gridActionType = NONE;
			case DRAG:
				selectionDragging = FlxG.mouse.pressed;
				if (selectionDragging) {
					gridBackdrops.draggingObj = null;
					selection.loop(function (n:CharterNote) {
						n.snappedToStrumline = false;
						n.setPosition(n.fullID * 40 + (mousePos.x - dragStartPos.x), n.step * 40 + (mousePos.y - dragStartPos.y));
						n.y = FlxMath.bound(n.y, 0, (__endStep*40) - n.height);
						n.x = FlxMath.bound(n.x, 0, ((strumLines.members.length * 4)-1) * 40);
						n.cursor = HAND;
					}, function (e:CharterEvent) {
						e.y =  e.step * 40 + (mousePos.y - dragStartPos.y) - 17;
						e.y = FlxMath.bound(e.y, -17, (__endStep*40)-17);
						e.cursor = HAND;
					});
					currentCursor = HAND;
				} else {
					var hoverOffset:FlxPoint = FlxPoint.get();
					for (s in selection)
						if (s.hovered) {
							hoverOffset.set(mousePos.x - s.x, mousePos.y - s.y);
							break;
						}
						
					dragStartPos.set(Std.int(dragStartPos.x / 40) * 40, dragStartPos.y); //credits to burgerballs
					var verticalChange:Float = ((mousePos.y - hoverOffset.y) - dragStartPos.y) / 40;
					var horizontalChange:Int = CoolUtil.floorInt((mousePos.x - dragStartPos.x) / 40);
					var undoDrags:Array<SelectionDragChange> = [];

					for (s in selection) {
						if (s.draggable) {
							var changePoint:FlxPoint = FlxPoint.get(verticalChange, horizontalChange);
							if (!FlxG.keys.pressed.SHIFT) changePoint.x -= ((s.step + verticalChange) - quantStepRounded(s.step+verticalChange));

							var boundedChange:FlxPoint = changePoint.clone();
							
							// Some maths, so cool bro -lunar (i dont know why i quopte my self here)
							if (s.step + changePoint.x < 0) boundedChange.x += Math.abs(s.step + changePoint.x);
							if (s.step + changePoint.x > __endStep-1) boundedChange.x -= (s.step + changePoint.x) - (__endStep-1);

							if (s is CharterNote) {
								var note:CharterNote = cast s;
								if (note.fullID + changePoint.y < 0) boundedChange.y += Math.abs(note.fullID + changePoint.y);
								if (note.fullID + changePoint.y > (strumLines.members.length*4)-1) boundedChange.y -= (note.fullID + changePoint.y) - ((strumLines.members.length*4)-1);
							}

							s.handleDrag(boundedChange);
							undoDrags.push({selectable:s, change: boundedChange});
							changePoint.put();
						}

						if (s is CharterNote) cast(s, CharterNote).snappedToStrumline = true;
						if (s is UISprite) cast(s, UISprite).cursor = BUTTON;
					}
					if (!(verticalChange == 0 && horizontalChange == 0)) {
						notesGroup.sortNotes(); eventsGroup.sortEvents();
						undos.addToUndo(CSelectionDrag(undoDrags));
					}

					hoverOffset.put();
					gridActionType = NONE;

					currentCursor = ARROW;
				}

			case NONE:
				if (FlxG.mouse.justPressed)
					FlxG.mouse.getWorldPosition(charterCamera, dragStartPos); 

				if (gridBackdropDummy.hovered) {
					// AUTO DETECT
					if (FlxG.mouse.pressed && (Math.abs(mousePos.x - dragStartPos.x) > 20 || Math.abs(mousePos.y - dragStartPos.y) > 20))
						gridActionType = BOX;

					var id = Math.floor(mousePos.x / 40);
					var mouseOnGrid = id >= 0 && id < 4 * gridBackdrops.strumlinesAmount && mousePos.y >= 0;
	
					if (FlxG.mouse.justReleased) {
							for (n in selection) n.selected = false;
							selection = [];
						
							if (mouseOnGrid && mousePos.y > 0 && mousePos.y < (__endStep)*40) {
								var note = new CharterNote();
								note.updatePos(
									FlxMath.bound(FlxG.keys.pressed.SHIFT ? ((mousePos.y-20) / 40) : quantStep(mousePos.y/40), 0, __endStep-1),
									id % 4, 0, noteType, strumLines.members[Std.int(id/4)]
								);
								notesGroup.add(note);
								selection = [note];
								undos.addToUndo(CCreateSelection([note]));
							}
					}
				} else if (gridBackdropDummy.hoveredByChild) {
					if (FlxG.mouse.pressed && (Math.abs(mousePos.x - dragStartPos.x) > 5 || Math.abs(mousePos.y - dragStartPos.y) > 5)) {
						var noteHovered:Bool = false;
						for(n in selection) 
							if (n.hovered) {
								noteHovered = true;
								break;
							}
						gridActionType = noteHovered ? DRAG : INVALID_DRAG;
					}
				}

				if (FlxG.mouse.justReleasedRight) {
					var mousePos = FlxG.mouse.getScreenPosition(uiCamera);
					closeCurrentContextMenu();
					openContextMenu(topMenu[1].childs, null, mousePos.x, mousePos.y);
					mousePos.put();
				}
		}
		addEventSpr.selectable = !selectionBox.visible;

		var inBoundsY:Bool = (mousePos.y > 0 && mousePos.y < (__endStep)*40);
		
		// Event Spr
		if (mousePos.x < 0 && mousePos.x > -addEventSpr.bWidth && gridActionType == NONE && inBoundsY) {
			addEventSpr.incorporeal = false;
			addEventSpr.sprAlpha = lerp(addEventSpr.sprAlpha, 0.75, 0.25);
			var event = getHoveredEvent(mousePos.y);
			if (event != null) addEventSpr.updateEdit(event);
			else addEventSpr.updatePos(FlxG.keys.pressed.SHIFT ? ((mousePos.y) / 40) : quantStepRounded(mousePos.y/40));
		} else  addEventSpr.sprAlpha = lerp(addEventSpr.sprAlpha, 0, 0.25);

		// Note Hoverer
		if (mousePos.x > 0 && mousePos.x < gridBackdrops.strumlinesAmount * 160 && gridActionType == NONE && inBoundsY) {
			noteHoverer.alpha = lerp(noteHoverer.alpha, 0.35, 0.25);
			if (noteHoverer.id != Math.floor(mousePos.x / 40) % 4) {
				@:privateAccess noteHoverer.__doAnim = false; // Un comment to restore this
				noteHoverer.updatePos(
					FlxMath.bound(FlxG.keys.pressed.SHIFT ? ((mousePos.y) / 40) : quantStep((mousePos.y+20)/40), 0, __endStep-1), 
					Math.floor(mousePos.x / 40) % 4, 0, 0, null
				);
			} else {
				noteHoverer.step = FlxMath.bound(FlxG.keys.pressed.SHIFT ? ((mousePos.y-20) / 40) : quantStep(mousePos.y/40), 0, __endStep-1);
				noteHoverer.y = noteHoverer.step * 40;
			}
			noteHoverer.x = lerp(noteHoverer.x, Math.floor(mousePos.x / 40) * 40, .65);
		} else
			noteHoverer.alpha = lerp(noteHoverer.alpha, 0, 0.25);
	}

	public function quantStep(step:Float):Float {
		var stepMulti:Float = 1/(quant/16);
		return Math.floor(step/stepMulti) * stepMulti;
	}

	public function quantStepRounded(step:Float):Float {
		var stepMulti:Float = 1/(quant/16);
		return Math.round(step/stepMulti) * stepMulti;
	}

	public function getHoveredEvent(y:Float) {
		var eventHovered:CharterEvent = null;
		eventsGroup.forEach(function(e) {
			if (eventHovered != null)
				return;

			if (e.hovered || (y >= e.y && y < (e.y + e.bHeight)))
				eventHovered = e;
		});
		return eventHovered;
	}

	public function deleteSingleSelection(selected:ICharterSelectable, addToUndo:Bool = true):Null<ICharterSelectable> {
		if (selected == null) return selected;

		if (selected is CharterNote) {
			var note:CharterNote = cast selected;
			note.strumLineID = strumLines.members.indexOf(note.strumLine);
			note.strumLine = null; // For static undos :D
			notesGroup.remove(note);
			note.kill();
		} else if (selected is CharterEvent) {
			var event:CharterEvent = cast selected;
			eventsGroup.remove(event);
			event.kill();
		}

		if (addToUndo)
			undos.addToUndo(CDeleteSelection([selected]));

		return null;
	}

	public function createSelection(selection:Selection, addToUndo:Bool = true) {
		if (selection.length <= 0) return [];

		notesGroup.autoSort = false;
		selection.loop(function (n:CharterNote) {
			n.strumLine = strumLines.members[n.strumLineID];
			n.revive();
			notesGroup.add(n);
		}, function (e:CharterEvent) {
			e.revive();
			eventsGroup.add(e);
			e.refreshEventIcons();
		}, false);
		notesGroup.sortNotes();
		notesGroup.autoSort = true;

		for (s in selection)
			if (s is CharterEvent) {
				Charter.instance.updateBPMEvents();
				break;
			}

		if (addToUndo)
			undos.addToUndo(CCreateSelection(selection));
		return [];
	}

	public function deleteSelection(selection:Selection, addToUndo:Bool = true) {
		if (selection.length <= 0) return [];

		notesGroup.autoSort = false;
		for (objects in [notesGroup, eventsGroup]) {
			var group = cast(objects, FlxTypedGroup<Dynamic>);
			var member = 0;
			while(member < group.members.length) {
				var s = group.members[member];
				if (selection.contains(s))
					deleteSingleSelection(s, false);
				else member++;
			}
		}
		notesGroup.sortNotes();
		notesGroup.autoSort = true;

		for (s in selection)
			if (s is CharterEvent) {
				Charter.instance.updateBPMEvents();
				break;
			}

		if (addToUndo)
			undos.addToUndo(CDeleteSelection(selection));
		return [];
	}

	// STRUMLINE DELETION/CREATION
	public function createStrumline(strumLineID:Int, strL:ChartStrumLine, addToUndo:Bool = true, ?__createNotes:Bool = true) {
		var cStr = new CharterStrumline(strL);
		strumLines.insert(strumLineID, cStr);
		strumLines.snapStrums();

		if (__createNotes) {
			var toBeCreated:Selection = [];
			for(note in strL.notes) {
				var n = new CharterNote();
				var t = Conductor.getStepForTime(note.time);
				n.updatePos(t, note.id, Conductor.getStepForTime(note.time + note.sLen) - t, note.type, cStr);
				notesGroup.add(n);
			}
			createSelection(toBeCreated, false);
		}

		if (addToUndo)
			undos.addToUndo(CCreateStrumLine(strumLineID, strL));
	}

	public function deleteStrumline(strumLineID:Int, addToUndo:Bool = true) {
		var undoNotes:Array<ChartNote> = [];
		removeStrumlineFromSelection(strumLineID);

		var i = 0;
		var toBeDeleted:Selection = [];
		for (note in notesGroup.members)
   			if (note.strumLineID == strumLineID) {
				undoNotes.push(buildNote(note));
				toBeDeleted.push(note);
			}
		deleteSelection(toBeDeleted, false);

		var strL = strumLines.members[strumLineID].strumLine;
		strumLines.members[strumLineID].destroy();
		strumLines.members.remove(strumLines.members[strumLineID]);
		strumLines.snapStrums();

		if (addToUndo) {
			var newStrL = Reflect.copy(strL);
			newStrL.notes = undoNotes;

			undos.addToUndo(CDeleteStrumLine(strumLineID, newStrL));
		}
	}

	public function getStrumlineID(strL:ChartStrumLine):Int {
		for (index=>strumLine in strumLines.members) {
			if (strumLine.strumLine == strL)
				return index;
		}
		return -1;
	}

	public function createStrumWithUI() {
		FlxG.state.openSubState(new CharterStrumlineScreen(strumLines.members.length, null, (_) -> {
			if (_ != null) {
				createStrumline(strumLines.members.length, _);

				strumlineAddButton.textTweenColor.color = 0xFF00FF00;
				strumlineAddButton.pressAnimation(true);
			}
		}));
	}

	public inline function deleteStrumlineFromData(strL:ChartStrumLine)
		deleteStrumline(getStrumlineID(strL));

	public inline function editStrumline(strL:ChartStrumLine) {
		var strID = getStrumlineID(strL);
		var oldData:ChartStrumLine = Reflect.copy(strL);

		FlxG.state.openSubState(new CharterStrumlineScreen(strID, strL, (_) -> {
			strumLines.members[strID].strumLine = _;
			strumLines.members[strID].updateInfo();

			undos.addToUndo(CEditStrumLine(strID, oldData, _));
		}));
	}

	public inline function removeStrumlineFromSelection(strumLineID:Int) {
		var i = 0;
		while(i < selection.length) {
			if (selection[i] is CharterNote) {
				var note:CharterNote = cast selection[i];
				if (note.strumLineID == strumLineID)
					selection.remove(note);
				else i++;
			}
		}
	}
	#end

	var __crochet:Float;
	var __firstFrame:Bool = true;
	public override function update(elapsed:Float) {
		updateNoteLogic(elapsed);

		if (FlxG.sound.music.playing || __firstFrame) {
			gridBackdrops.conductorSprY = curStepFloat * 40;
		} else {
			gridBackdrops.conductorSprY = lerp(gridBackdrops.conductorSprY, curStepFloat * 40, __firstFrame ? 1 : 1/3);
		}
		charterCamera.scroll.set(
			((((40*4) * gridBackdrops.strumlinesAmount) - FlxG.width) / 2),
			gridBackdrops.conductorSprY - (FlxG.height * 0.5)
		);

		if (topMenuSpr.members[playbackIndex] != null) {
			var playBackButton:UITopMenuButton = cast topMenuSpr.members[playbackIndex];
			playBackButton.x = playBackSlider.x-playBackSlider.startText.width-10-playBackSlider.valueStepper.bWidth-playBackButton.bWidth-10;
			playBackButton.label.offset.x = -1;

			if (topMenuSpr.members[snapIndex] != null) {
				var snapButton:UITopMenuButton = cast topMenuSpr.members[snapIndex];
				var lastButtonX = playBackButton.x-10;

				var buttonI:Int = 0;
				for (button in quantButtons) {
					button.visible = ((button.quant == quant) || 
						(button.quant == quants[FlxMath.wrap(quants.indexOf(quant)-1, 0, quants.length-1)]) || 
						(button.quant == quants[FlxMath.wrap(quants.indexOf(quant)+1, 0, quants.length-1)]));
					button.selectable = button.visible;
					if (!button.visible) continue;

					button.x = lastButtonX -= button.bWidth;
					button.framesOffset = button.quant == quant ? 9 : 0;
					button.alpha = button.quant == quant ? 1 : (button.hovered ? 0.4 : 0);
				}
				snapButton.x = (lastButtonX -= snapButton.bWidth)-10;
			}
		}

		if (topMenuSpr.members[noteIndex] != null) {
			var noteTopButton:UITopMenuButton = cast topMenuSpr.members[noteIndex];
			noteTypeText.x = noteTopButton.x + noteTopButton.bWidth + 6;
			noteTypeText.y = Std.int((noteTopButton.bHeight - noteTypeText.height) / 2);
		}
		noteTypeText.text = '($noteType) ${noteTypes[noteType-1] == null ? "Default Note" : noteTypes[noteType-1]}';
		
		super.update(elapsed);

		scrollBar.size = (FlxG.height / 40 / charterCamera.zoom);
		scrollBar.start = Conductor.curStepFloat - (scrollBar.size / 2);

		if (gridBackdrops.strumlinesAmount != strumLines.members.length)
			updateDisplaySprites();

		// TODO: canTypeText in case an ui input element is focused
		if (true) {
			__crochet = ((60 / Conductor.bpm) * 1000);

			if(FlxG.keys.justPressed.ANY && !strumLines.isDragging && this.currentFocus == null)
				UIUtil.processShortcuts(topMenu);

			if (FlxG.keys.pressed.CONTROL) {
				if (FlxG.mouse.wheel != 0) {
					zoom += 0.25 * FlxG.mouse.wheel;
					__camZoom = Math.pow(2, zoom);
				}
			} else {
				if (!FlxG.sound.music.playing) {
					Conductor.songPosition -= (__crochet * FlxG.mouse.wheel) - Conductor.songOffset;
				}
			}
		}

		var songLength = FlxG.sound.music.getDefault(vocals).length;
		Conductor.songPosition = FlxMath.bound(Conductor.songPosition + Conductor.songOffset, 0, songLength);

		if (Conductor.songPosition >= songLength - Conductor.songOffset) {
			FlxG.sound.music.pause();
			vocals.pause();
			for (strumLine in strumLines.members) strumLine.vocals.pause();
		}

		songPosInfo.text = '${CoolUtil.timeToStr(Conductor.songPosition)} / ${CoolUtil.timeToStr(songLength)}'
		+ '\nStep: ${curStep}'
		+ '\nBeat: ${curBeat}'
		+ '\nMeasure: ${curMeasure}'
		+ '\nBPM: ${Conductor.bpm}'
		+ '\nTime Signature: ${Conductor.beatsPerMeasure}/${Conductor.stepsPerBeat}';

		if (charterCamera.zoom != (charterCamera.zoom = lerp(charterCamera.zoom, __camZoom, __firstFrame ? 1 : 0.125)))
			updateDisplaySprites();

		if (strumLines != null)
			strumlineLockButton.button.animation.play(strumLines.draggable ? "1" : "0", true);

		WindowUtils.prefix = undos.unsaved ? "* " : "";
		SaveWarning.showWarning = undos.unsaved;

		__firstFrame = false;
	}

	public static var startTime:Float = 0;
	public static var startHere:Bool = false;

	function updateDisplaySprites() {
		gridBackdrops.strumlinesAmount = strumLines.members.length;

		charterBG.scale.set(1 / charterCamera.zoom, 1 / charterCamera.zoom);

		strumlineInfoBG.scale.set(FlxG.width / charterCamera.zoom, 1);
		strumlineInfoBG.updateHitbox();
		strumlineInfoBG.screenCenter(X);
		strumlineInfoBG.y = -(((FlxG.height - (2 * topMenuSpr.bHeight)) / charterCamera.zoom) - FlxG.height) / 2;

		for(id=>str in strumLines.members)
			if (str != null) str.y = strumlineInfoBG.y;

		strumlineAddButton.y = strumlineInfoBG.y;
		strumlineLockButton.y = strumlineInfoBG.y;
	}

	var zoom(default, set):Float = 0;
	var __camZoom(default, set):Float = 1;
	function set_zoom(val:Float) {
		return zoom = FlxMath.bound(val, -3.5, 1.75); // makes zooming not lag behind when continuing scrolling
	}
	function set___camZoom(val:Float) {
		return __camZoom = FlxMath.bound(val, 0.1, 3);
	}

	// TOP MENU OPTIONS
	#if REGION
	function _file_exit(_) {
		if (undos.unsaved) SaveWarning.triggerWarning();
		else {undos = null; FlxG.switchState(new CharterSelection()); PlayState.resetSongInfos(); Charter.instance.__clearStatics();}
	}

	function _file_save(_) {
		#if sys
		saveTo('${Paths.getAssetsRoot()}/songs/${__song.toLowerCase()}');
		undos.save();
		return;
		#end
		_file_saveas(_);
	}

	function _file_saveas(_) {
		openSubState(new SaveSubstate(Json.stringify(Chart.filterChartForSaving(PlayState.SONG, false)), {
			defaultSaveFile: '${__diff.toLowerCase()}.json'
		}));
		undos.save();
	}

	function _file_meta_save(_) {
		#if sys
		sys.io.File.saveContent(
			'${Paths.getAssetsRoot()}/songs/${__song.toLowerCase()}/meta.json',
			Json.stringify(PlayState.SONG.meta == null ? {} : PlayState.SONG.meta, null, "\t")
		);
		return;
		#end
		_file_meta_saveas(_);
	}

	function _file_meta_saveas(_) {
		openSubState(new SaveSubstate(Json.stringify(PlayState.SONG.meta == null ? {} : PlayState.SONG.meta, null, "\t"), { // always pretty print meta
			defaultSaveFile: 'meta.json'
		}));
	}

	#if sys
	function saveTo(path:String) {
		buildChart();
		Chart.save(path, PlayState.SONG, __diff.toLowerCase(), {saveMetaInChart: false});
	}
	#end

	function _edit_copy(_) {
		if(selection.length == 0) return;

		var minStep:Float = selection[0].step;
		for(s in selection)
			if (s.step < minStep) minStep = s.step;

		clipboard = [
			for (s in selection)
				if (s is CharterNote) {
				var note:CharterNote = cast s;
				CNote(note.step - minStep, note.id, note.strumLineID, note.susLength, note.type);
			} else if (s is CharterEvent) {
				var event = cast(s,CharterEvent);
				CEvent(event.step - minStep, [for (event in event.events) Reflect.copy(event)]);
			}
		];
	}
	function _edit_paste(_) {
		if (clipboard.length <= 0) return;

		var minStep = curStep;
		var sObjects:Array<ICharterSelectable> = [];
		for(c in clipboard) {
			switch(c) {
				case CNote(step, id, strumLineID, susLength, type):
					var note = new CharterNote();
					note.updatePos(minStep + step, id, susLength, type, strumLines.members[Std.int(FlxMath.bound(strumLineID, 0, strumLines.length-1))]);
					notesGroup.add(note);
					sObjects.push(note);
				case CEvent(step, events):
					var event = new CharterEvent(minStep + step, events);
					event.refreshEventIcons();
					eventsGroup.add(event);
					sObjects.push(event);
			}
		}
		selection = sObjects;
		_edit_copy(_); // to fix stupid bugs
		
		undos.addToUndo(CCreateSelection(sObjects.copy()));
	}

	function _edit_cut(_) {
		if (selection == null || selection.length == 0) return;

		_edit_copy(_);
		deleteSelection(selection, false);
	}

	function _edit_delete(_) {
		if (selection == null || selection.length == 0) return;
		selection = deleteSelection(selection);
	}

	function _edit_undo(_) {
		if (strumLines.isDragging || selectionDragging || subState != null) return;
		
		selection = [];
		var undo = undos.undo();
		switch(undo) {
			case null: // do nothing
			case CDeleteStrumLine(strumLineID, strumLine):
				createStrumline(strumLineID, strumLine, false);
			case CCreateStrumLine(strumLineID, strumLine):
				deleteStrumline(strumLineID, false);
			case COrderStrumLine(strumLineID, oldID, newID):
				var strumLine:CharterStrumline = strumLines.members[strumLineID];
				strumLines.orderStrumline(strumLine, oldID);
				undos.redoList[0] = COrderStrumLine(strumLines.members.indexOf(strumLine), oldID, newID);
			case CEditStrumLine(strumLineID, oldStrumLine, newStrumLine):
				strumLines.members[strumLineID].strumLine = oldStrumLine;
				strumLines.members[strumLineID].updateInfo();
			case CCreateSelection(selection):
				deleteSelection(selection, false);
			case CDeleteSelection(selection):
				createSelection(selection, false);
			case CSelectionDrag(selectionDrags):
				for (s in selectionDrags)
					if (s.selectable.draggable) s.selectable.handleDrag(s.change * -1);
					
				selection = [for (s in selectionDrags) s.selectable];
			case CEditSustains(changes):
				for(n in changes)
					n.note.updatePos(n.note.step, n.note.id, n.before, n.note.type);
			case CEditEvent(event, oldEvents, newEvents):
				event.events = oldEvents.copy();
				event.refreshEventIcons();

				Charter.instance.updateBPMEvents();
			case CEditChartData(oldData, newData):
				PlayState.SONG.stage = oldData.stage;
				PlayState.SONG.scrollSpeed = oldData.speed;
			case CEditNoteTypes(oldArray, newArray):
				noteTypes = oldArray;
				changeNoteType(null, false);
			case CEditSpecNotesType(notes, oldTypes, newTypes):
				for(i=>note in notes) note.updatePos(note.step, note.id, note.susLength, oldTypes[i]);
		}
	}

	function _edit_redo(_) {
		if (strumLines.isDragging || selectionDragging || subState != null) return;

		selection = [];
		var redo = undos.redo();
		switch(redo) {
			case null: // do nothing
			case CDeleteStrumLine(strumLineID, strumLine):
				deleteStrumline(strumLineID, false);
			case CCreateStrumLine(strumLineID, strumLine):
				createStrumline(strumLineID, strumLine, false);
			case COrderStrumLine(strumLineID, oldID, newID):
				var strumLine:CharterStrumline = strumLines.members[strumLineID];
				strumLines.orderStrumline(strumLine, newID);
				undos.undoList[0] = COrderStrumLine(strumLines.members.indexOf(strumLine), oldID, newID);
			case CEditStrumLine(strumLineID, oldStrumLine, newStrumLine):
				strumLines.members[strumLineID].strumLine = newStrumLine;
				strumLines.members[strumLineID].updateInfo();
			case CCreateSelection(selection):
				createSelection(selection, false);
			case CDeleteSelection(selection):
				deleteSelection(selection, false);
			case CSelectionDrag(selectionDrags):
				for (s in selectionDrags)
					if (s.selectable.draggable) s.selectable.handleDrag(s.change);
				//this.selection = selection;
			case CEditSustains(changes):
				for(n in changes)
					n.note.updatePos(n.note.step, n.note.id, n.after, n.note.type);
			case CEditEvent(event, oldEvents, newEvents):
				event.events = newEvents.copy();
				event.refreshEventIcons();

				Charter.instance.updateBPMEvents();
			case CEditChartData(oldData, newData):
				PlayState.SONG.stage = newData.stage;
				PlayState.SONG.scrollSpeed = newData.speed;
			case CEditNoteTypes(oldArray, newArray):
				noteTypes = newArray;
				changeNoteType(null, false);
			case CEditSpecNotesType(notes, oldTypes, newTypes):
				for(i=>note in notes) note.updatePos(note.step, note.id, note.susLength, newTypes[i]);
		}
	}

	inline function _chart_playtest(_)
		playtestChart(0, false);
	inline function _chart_playtest_here(_)
		playtestChart(Conductor.songPosition, false, true);
	inline function _chart_playtest_opponent(_)
		playtestChart(0, true);
	inline function _chart_playtest_opponent_here(_)
		playtestChart(Conductor.songPosition, true, true);
	function _chart_enablescripts(t) {
		t.icon = (Options.charterEnablePlaytestScripts = !Options.charterEnablePlaytestScripts) ? 1 : 0;
	}

	function chart_edit_data(_)
		FlxG.state.openSubState(new ChartDataScreen(PlayState.SONG));
	function chart_edit_metadata(_)
		FlxG.state.openSubState(new MetaDataScreen(PlayState.SONG.meta));

	function _playback_play(_) {
		if (Conductor.songPosition >= FlxG.sound.music.getDefault(vocals).length - Conductor.songOffset) return;

		if (FlxG.sound.music.playing) {
			FlxG.sound.music.pause();
			vocals.pause();
			for (strumLine in strumLines.members) strumLine.vocals.pause();
		} else {
			FlxG.sound.music.play();
			vocals.play();
			vocals.time = FlxG.sound.music.time = Conductor.songPosition + Conductor.songOffset * 2;
			for (strumLine in strumLines.members) {
				strumLine.vocals.play();
				strumLine.vocals.time = vocals.time;
			}
		}
	}

	function _playback_speed_raise(_) playBackSlider.value += .25;
	function _playback_speed_reset(_) playBackSlider.value = 1;
	function _playback_speed_lower(_) playBackSlider.value -= .25;

	function _playback_metronome(t) {
		t.icon = (Options.charterMetronomeEnabled = !Options.charterMetronomeEnabled) ? 1 : 0;
	}
	function _song_muteinst(t) {
		FlxG.sound.music.volume = FlxG.sound.music.volume > 0 ? 0 : 1;
		t.icon = 1 - Std.int(Math.ceil(FlxG.sound.music.volume));
	}
	function _song_mutevoices(t) {
		vocals.volume = vocals.volume > 0 ? 0 : 1;
		for (strumLine in strumLines.members) strumLine.vocals.volume = strumLine.vocals.volume > 0 ? 0 : 1;
		t.icon = 1 - Std.int(Math.ceil(vocals.volume));
	}
	function _playback_back(_) {
		if (FlxG.sound.music.playing) return;
		Conductor.songPosition -= (Conductor.beatsPerMeasure * __crochet);
	}
	function _playback_forward(_) {
		if (FlxG.sound.music.playing) return;
		Conductor.songPosition += (Conductor.beatsPerMeasure * __crochet);
	}
	function _song_start(_) {
		if (FlxG.sound.music.playing) return;
		Conductor.songPosition = 0;
	}
	function _song_end(_) {
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
	function _view_showeventSecSeparator(t) {
		t.icon = (Options.charterShowSections = !Options.charterShowSections) ? 1 : 0;
		eventsBackdrop.eventSecSeparator.visible = gridBackdrops.sectionsVisible = Options.charterShowSections;
	}
	function _view_showeventBeatSeparator(t) {
		t.icon = (Options.charterShowBeats = !Options.charterShowBeats) ? 1 : 0;
		eventsBackdrop.eventBeatSeparator.visible = gridBackdrops.beatsVisible = Options.charterShowBeats;
	}
	inline function _snap_increasesnap(_) changequant(1);
	inline function _snap_decreasesnap(_) changequant(-1);
	inline function _snap_resetsnap(_) setquant(16);

	inline function changequant(change:Int) {quant = quants[FlxMath.wrap(quants.indexOf(quant) + change, 0, quants.length-1)]; buildSnapsUI();};
	inline function setquant(newquant:Int) {quant = newquant; buildSnapsUI();}

	function buildSnapsUI():Array<UIContextMenuOption> {
		var snapsTopButton:UITopMenuButton = topMenuSpr == null ? null : cast topMenuSpr.members[snapIndex];
		var newChilds:Array<UIContextMenuOption> = [
			{
				label: "↑ Grid Snap",
				keybind: [X],
				onSelect: _snap_increasesnap
			},
			{
				label: "Reset Grid Snap",
				onSelect: _snap_resetsnap
			},
			{
				label: "↓ Grid Snap",
				keybind: [Z],
				onSelect: _snap_decreasesnap
			},
			null
		];

		for (_quant in quants) 
			newChilds.push({
				label: '${_quant}x Grid Snap',
				onSelect: (_) -> {setquant(_quant); buildSnapsUI();},
				icon: _quant == quant ? 1 : 0
			});

		if (snapsTopButton != null) snapsTopButton.contextMenu = newChilds;
		return newChilds;
	}

	inline function _note_addsustain(t)
		changeNoteSustain(1);

	inline function _note_subtractsustain(t)
		changeNoteSustain(-1);

	function _note_selectall(_) {
		selection = [for (note in notesGroup.members) note];
	} 

	function _note_selectmeasure(_) {
		selection = [for (note in notesGroup.members)
			if (note.step > Conductor.curMeasure*Conductor.getMeasureLength() && note.step < (Conductor.curMeasure+1)*Conductor.getMeasureLength()) note
		];
	}

	#end

	function changeNoteSustain(change:Float) {
		if (selection.length <= 0 || change == 0) return;

		var undoChanges:Array<NoteSustainChange> = [];
		for(s in selection)
			if (s is CharterNote) {
				var n:CharterNote = cast s;
				var old:Float = n.susLength;
				n.updatePos(n.step, n.id, Math.max(n.susLength + change, 0));
				undoChanges.push({before: old, after: n.susLength, note: n});
			}

		undos.addToUndo(CEditSustains(undoChanges));
	}

	inline public function changeNoteType(?newID:Int, checkSelection:Bool = true) {
		if(newID != null) noteType = newID;
		noteType = Std.int(FlxMath.bound(noteType, 0, noteTypes.length));
		buildNoteTypesUI();

		var changedNotes:{notes:Array<CharterNote>, oldTypes:Array<Int>, newTypes:Array<Int>} = {notes:[], oldTypes:[], newTypes:[]};
		for(note in notesGroup) if(note.type < 0 || note.type > noteTypes.length) {
			changedNotes.notes.push(note); changedNotes.oldTypes.push(note.type); changedNotes.newTypes.push(0);
			note.updatePos(note.step, note.id, note.susLength, 0);
		}

		if(checkSelection) for(s in selection)
			if (s is CharterNote) {
				var n:CharterNote = cast s;
				changedNotes.notes.push(n); changedNotes.oldTypes.push(n.type); changedNotes.newTypes.push(newID);
				n.updatePos(n.step, n.id, n.susLength, newID);
			}
		if(changedNotes.notes.length > 0) undos.addToUndo(CEditSpecNotesType(changedNotes.notes, changedNotes.oldTypes, changedNotes.newTypes));
	}

	function editNoteTypesList(_)
		FlxG.state.openSubState(new CharterNoteTypesList());

	function buildNoteTypesUI():Array<UIContextMenuOption> {
		var noteTopButton:UITopMenuButton = topMenuSpr == null ? null : cast topMenuSpr.members[noteIndex];
		var newChilds:Array<UIContextMenuOption> = [
			{
				label: "Add sustain length",
				keybind: [E],
				onSelect: _note_addsustain
			},
			{
				label: "Subtract sustain length",
				keybind: [Q],
				onSelect: _note_subtractsustain
			},
			null,
			{
				label: "Select all",
				keybind: [CONTROL, A],
				onSelect: _note_selectall
			},
			{
				label: "Select measure",
				keybind: [CONTROL, SHIFT, A],
				onSelect: _note_selectmeasure
			},
			null,
			{
				label: "(0) Default Note",
				keybind: [ZERO],
				onSelect: (_) -> {changeNoteType(0);},
				icon: this.noteType == 0 ? 1 : 0
			}
		];

		var noteKeys:Array<FlxKey> = [ZERO, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE];
		for (i=>type in noteTypes) {
			var realNoteID:Int = i+1; // Default Note not stored
			var newChild:UIContextMenuOption = {
				label: '(${realNoteID}) ${type}',
				onSelect: (_) -> {changeNoteType(realNoteID);},
				icon: this.noteType == realNoteID ? 1 : 0
			};
			if (realNoteID <= 9) newChild.keybind = [noteKeys[realNoteID]];
			newChilds.push(newChild);
		}
		newChilds.push({
			label: "Edit Note Types List",
			color: 0xFF959829, icon: 4,
			onCreate: function (button:UIContextMenuOptionSpr) {button.label.offset.x = button.icon.offset.x = -2;},
			onSelect: editNoteTypesList
		});
		if (noteTopButton != null) noteTopButton.contextMenu = newChilds;
		return newChilds;
	}

	public function playtestChart(time:Float = 0, opponentMode = false, here = false) {
		buildChart();
		startHere = here;
		startTime = Conductor.songPosition;
		PlayState.opponentMode = opponentMode;
		PlayState.chartingMode = true;
		FlxG.switchState(new PlayState());
	}

	public inline function buildNote(note:CharterNote):ChartNote {
		var time = Conductor.getTimeForStep(note.step);
		return {
			type: note.type,
			time: time,
			sLen: Conductor.getTimeForStep(note.step + note.susLength) - time,
			id: note.id
		};
	}

	public function buildChart() {
		PlayState.SONG.strumLines = [];
		PlayState.SONG.noteTypes = this.noteTypes;
		for(s in strumLines) {
			s.strumLine.notes = [];
			PlayState.SONG.strumLines.push(s.strumLine);
		}
		notesGroup.sortNotes();
		for(n in notesGroup.members) {
			if (PlayState.SONG.strumLines[n.strumLineID] != null) 
				PlayState.SONG.strumLines[n.strumLineID].notes.push(buildNote(n));
		}
		buildEvents();
	}

	public function buildEvents() {
		PlayState.SONG.events = [];
		eventsGroup.sortEvents();
		for(e in eventsGroup.members) {
			for(event in e.events) {
				event.time = Conductor.getTimeForStep(e.step);
				PlayState.SONG.events.push(event);
			}
		}
	}

	public function updateBPMEvents() {
		buildEvents();

		Conductor.mapBPMChanges(PlayState.SONG);
		Conductor.changeBPM(PlayState.SONG.meta.bpm, cast PlayState.SONG.meta.beatsPerMeasure.getDefault(4), cast PlayState.SONG.meta.stepsPerBeat.getDefault(4));

		refreshBPMSensitive();
	}

	public inline function hitsoundsEnabled(id:Int)
		return strumLines.members[id] != null && strumLines.members[id].hitsounds;

	// UH OH!!! DANGER ZONE APPOARCHING !!!! LUNARS SHITTY CODE !!!! -lunar

	@:noCompletion public function __fixSingleSelection(selectable:ICharterSelectable):ICharterSelectable {
		if (selectable is CharterNote)
			return selectable.ID == -1 ? cast(selectable, CharterNote) : notesGroup.members[selectable.ID];
		else if (selectable is CharterEvent)
			return selectable.ID == -1 ? cast(selectable, CharterEvent) : eventsGroup.members[selectable.ID];
		return null;
	}

	@:noCompletion public function __fixSelection(selection:Selection) @:privateAccess {
		var newSelection:Selection = new Selection();
		for (i => selectable in selection)
			newSelection[i] = __fixSingleSelection(selectable);
		return newSelection;
	}

	@:noCompletion public inline function __relinkSelection()
		selection = __fixSelection(selection);

	@:noCompletion public inline function __relinkUndos() {
		for (list => changeList in [undos.undoList, undos.redoList]) {
			var newChanges:Array<CharterChange> = [];
			for (i => change in changeList) {
				switch (change) {
					case CCreateSelection(selection):
						newChanges[i] = CCreateSelection(__fixSelection(selection));
					case CDeleteSelection(selection):
					 	newChanges[i] = CDeleteSelection(__fixSelection(selection));
					case CSelectionDrag(selectionDrags):
						newChanges[i] = CSelectionDrag([
							for (selectionDrag in selectionDrags)
								{
									selectable: __fixSingleSelection(selectionDrag.selectable), 
									change: selectionDrag.change
								}
						]);
					case CEditSustains(noteChanges):
						newChanges[i] = CEditSustains([
							for (noteChange in noteChanges)
								{
									note: cast(__fixSingleSelection(noteChange.note), CharterNote),
									before: noteChange.before,
									after: noteChange.after
								}
						]);
					case CEditEvent(event, oldEvents, newEvents):
						newChanges[i] = CEditEvent(cast(__fixSingleSelection(event), CharterEvent), oldEvents, newEvents);
					case CEditSpecNotesType(notesChanged, oldNoteTypes, newNoteTypes):
						newChanges[i] = CEditSpecNotesType([
							for (noteChanged in notesChanged)
								cast(__fixSingleSelection(noteChanged), CharterNote)
						], oldNoteTypes, newNoteTypes);
					default: newChanges[i] = change;
				}
			}

			if (list == 0) undos.undoList = newChanges;
			else undos.redoList = newChanges;
		}
	}

	@:noCompletion public function __resetStatics() {
		selection = new Selection();
		undos = new UndoList<CharterChange>();
		clipboard = []; playtestInfo = null;
	}

	@:noCompletion public function __clearStatics() {
		selection = null; undos = null; clipboard = null; playtestInfo = null;
	}

	@:noCompletion public function __updatePlaytestInfo() {
		playtestInfo = {
			songPosition: Conductor.songPosition,
			playbackSpeed: playBackSlider.value,
			quantSelected: quant,
			noteTypeSelected: noteType, 
			strumlinesDraggable: strumLines.draggable,
			hitSounds: [for (strumLine in strumLines.members) strumLine.hitsounds],
			mutedVocals: [for (strumLine in strumLines.members) !(strumLine.vocals.volume > 0)],
		}
	}

	@:noCompletion public function __applyPlaytestInfo() {
		if (playtestInfo == null) return;

		Conductor.songPosition = playtestInfo.songPosition;
		playBackSlider.value = playtestInfo.playbackSpeed;
		quant = playtestInfo.quantSelected;
		noteType = playtestInfo.noteTypeSelected;
		strumLines.draggable = playtestInfo.strumlinesDraggable;

		for (i => strumLine in strumLines.members)
			strumLine.hitsounds = playtestInfo.hitSounds[i];
		for (i => strumLine in strumLines.members)
			strumLine.vocals.volume = playtestInfo.mutedVocals[i] ? 0 : 1;
	}
}

enum CharterChange {
	CCreateStrumLine(strumLineID:Int, strumLine:ChartStrumLine);
	CEditStrumLine(strumLineID:Int, oldStrumLine:ChartStrumLine, newStrumLine:ChartStrumLine);
	COrderStrumLine(strumLineID:Int, oldID:Int, newID:Int);
	CDeleteStrumLine(strumLineID:Int, strumLine:ChartStrumLine);
	CCreateSelection(selection:Selection);
	CDeleteSelection(selection:Selection);
	CSelectionDrag(selectionDrags:Array<SelectionDragChange>);
	CEditSustains(notes:Array<NoteSustainChange>);
	CEditEvent(event:CharterEvent, oldEvents:Array<ChartEvent>, newEvents:Array<ChartEvent>);
	CEditChartData(oldData:{stage:String, speed:Float}, newData:{stage:String, speed:Float});
	CEditNoteTypes(oldArray:Array<String>, newArray:Array<String>);
	CEditSpecNotesType(notes:Array<CharterNote>, oldNoteTypes:Array<Int>, newNoteTypes:Array<Int>);
}

enum CharterCopyboardObject {
	CNote(step:Float, id:Int, strumLineID:Int, susLength:Float, type:Int);
	CEvent(step:Float, events:Array<ChartEvent>);
}

typedef NoteSustainChange = {
	var note:CharterNote;
	var before:Float;
	var after:Float;
}

typedef SelectionDragChange = {
	var selectable:ICharterSelectable;
	var change:FlxPoint;
}

@:forward abstract Selection(Array<ICharterSelectable>) from Array<ICharterSelectable> to Array<ICharterSelectable> {
	public inline function new(?array:Array<ICharterSelectable>)
		this = array == null ? [] : array;

	// too lazy to put this in every for loop so i made it a abstract
	public inline function loop(onNote:CharterNote->Void, ?onEvent:CharterEvent->Void, ?draggableOnly:Bool = true) {
		for (s in this) {
			if (s is CharterNote && onNote != null && (draggableOnly ? s.draggable: true))
				onNote(cast(s, CharterNote));
			else if (s is CharterEvent && onEvent != null && (draggableOnly ? s.draggable: true))
				onEvent(cast(s, CharterEvent));
		}
	}
}

interface ICharterSelectable {
	public var x(default, set):Float;
	public var y(default, set):Float;
	public var ID:Int;
	public var step:Float;

	public var selected:Bool;
	public var hovered:Bool;
	public var draggable:Bool;

	public function handleSelection(selectionBox:UISliceSprite):Bool;
	public function handleDrag(change:FlxPoint):Void;
}

enum abstract CharterGridActionType(Int) {
	var NONE = 0;
	var BOX = 1;
	var DRAG = 2;
	var INVALID_DRAG = 3;
}

typedef PlaytestInfo = {
	var songPosition:Float;
	var playbackSpeed:Float;
	var quantSelected:Int;
	var noteTypeSelected:Int;
	var strumlinesDraggable:Bool;
	var hitSounds:Array<Bool>;
	var mutedVocals:Array<Bool>;
}