package funkin.editors.character;

import funkin.backend.system.framerate.Framerate;
import funkin.backend.FlxAnimate;
import flixel.group.FlxSpriteGroup;
import flixel.graphics.FlxGraphic;
import funkin.backend.utils.XMLUtil.AnimData;
import flixel.math.FlxPoint;
import funkin.editors.ui.UIContextMenu.UIContextMenuOption;
import funkin.game.Character;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import flixel.util.FlxColor;

class CharacterEditor extends UIState
{
	public var blockedInputs = [];
	public var blockedStuff = [];

	public var curChar:String;

	public var char:Character;
	public var ghostChar:Character;
	public var charLayer:FlxTypedSpriteGroup<Character> = new FlxTypedSpriteGroup<Character>(0, 0);
	public var animAtlas:FlxAnimate;

	public var cameraPointer:FlxSprite;

	public var camFollow:FlxObject;
	public var editorCamera:FlxCamera;
	public var uiCamera:FlxCamera;

	public var topMenu:Array<UIContextMenuOption>;
	public var topMenuSpr:UITopMenu;

	public var uiGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	public var stage:FlxTypedSpriteGroup<FunkinSprite> = new FlxTypedSpriteGroup<FunkinSprite>(0, 0);

	public var curAnim:Int = 0;

	public var playingAnim:UIText;
	public var currentChar:UIText;
	public var movingCamText:UIText;

	//Healthbar
	public var healthBarBG:FlxSprite;
	public var icon:FlxSprite;

	public var camZoom(default, set):Float = 1;

	public function new(charName:String)
	{
		super();
		this.curChar = charName;
	}

	override function create()
	{
		super.create();

		// Camera setup
		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);
		editorCamera = FlxG.camera;
		uiCamera = new FlxCamera();
		uiCamera.bgColor = 0;
		FlxG.cameras.add(uiCamera, false);
		FlxG.camera.follow(camFollow);

		// Add Stage and Centered Cross
		add(stage);
		add(ofs_cross);
		loadCross();

		// Indicators
		var pointer:FlxGraphic = FlxGraphic.fromClass(GraphicCursorCross);
		cameraPointer = new FlxSprite().loadGraphic(pointer);
		cameraPointer.setGraphicSize(40, 40);
		cameraPointer.updateHitbox();
		cameraPointer.color = FlxColor.WHITE;

		// Character
		add(charLayer);
		add(cameraPointer);
		loadChar(!CharacterConfig.loadCharacterData(curChar).isPlayer);

		// Reload Stage
		reloadStage();

		// UI
		loadUI();

		playingAnim = new UIText(846.62, 64.23, 0, 'Animation: ${char.characterData.animations[curAnim].name}', 24);
		playingAnim.alignment = LEFT;
		playingAnim.cameras = [uiCamera];

		currentChar = new UIText(846.62, 30.23, 0, 'Character: ${char.curCharacter}', 24);
		currentChar.alignment = LEFT;
		currentChar.cameras = [uiCamera];

		movingCamText = new UIText((FlxG.width / 4) - 310, (FlxG.height / 2), -1,
			"Press the left mouse button anywhere on this stage to set the character's camera position.", 24);
		movingCamText.cameras = [uiCamera];
		movingCamText.visible = false;

		//Health Bar
		healthBarBG = new FlxSprite(747, 102).loadGraphic(Paths.image('game/healthBar'));
		healthBarBG.setGraphicSize(399,13);
		healthBarBG.scrollFactor.set();
		healthBarBG.cameras = [uiCamera];


		var charData:CharacterData;
		charData = char.characterData;

		var path = Paths.image('icons/${charData.icon}');
		if (!Assets.exists(path)) path = Paths.image('icons/face');

		//Show both Losing Normal Icons
		icon = new FlxSprite(754, 86).loadGraphic(path);
		icon.scale.set(0.5,0.5);
		icon.scrollFactor.set();
		icon.cameras = [uiCamera];





		healthBarBG.color = charData.iconColor;

		// Top Menu
		add(currentChar);
		add(playingAnim);
		add(icon);
		add(healthBarBG);
		add(movingCamText);
		add(topMenuSpr);
		add(uiGroup);
	}

	override function update(elapsed:Float)
	{
		// Control
		controlCamera(elapsed);
		controlCharacter();
		changeAnim();
		moveCharPos();
		detectCamClick();
		mouseControl();

		ghostChar.setPosition(char.x, char.y);
		super.update(elapsed);
	}

	public function reloadIcon()
		{
			var charData:CharacterData;
			charData = char.characterData;
			
			var path = Paths.image('icons/${charData.icon}');
			if (!Assets.exists(path)) path = Paths.image('icons/face');
			icon.loadGraphic(path);
		}

	public function searchAnim(name:String, ?array:Array<AnimData>):AnimData
	{
		if (array == null)
			array = char.characterData.animations;
		for (i in 0...array.length - 1)
			if (array[i].name == name)
				return array[i];
		return array[0];
	}

	public function getAnimIndex(name:String, ?array:Array<AnimData>):Int
	{
		if (array == null)
			array = char.characterData.animations;
		for (i in 0...array.length - 1)
			if (array[i].name == name)
				return i;
		return 0;
	}

	function resortAnims(animations:Array<AnimData>)
	{
		// TODO: add support for danceLeft danceRight
		if (getAnimIndex("idle") != 0)
		{
			var oldanims = animations.copy();
			animations.clear();
			animations.push(searchAnim("idle", oldanims));
			for (anim in oldanims)
				if (anim != searchAnim("idle", oldanims))
					animations.push(anim);
		}
	}

	public function reloadChar(isOpponent:Bool, charData:CharacterData)
	{
		var i:Int = charLayer.members.length - 1;
		while (i >= 0)
		{
			var memb:Character = charLayer.members[i];
			if (memb != null)
			{
				memb.kill();
				charLayer.remove(memb);
				memb.destroy();
			}
			--i;
		}
		charLayer.clear();
		ghostChar = new Character(0, 0, curChar, !isOpponent);
		ghostChar.characterData = charData;
		ghostChar.debugMode = true;
		ghostChar.alpha = 0.6;

		char = new Character(0, 0, curChar, !isOpponent);
		char.characterData = charData;

		var charData = char.characterData;
		resortAnims(charData.animations);
		var availableAnim = searchAnim("idle");
		curAnim = getAnimIndex("idle");
		ghostChar.characterData.animations = char.characterData.animations;
		char.playAnim(availableAnim.name, true);
		ghostChar.playAnim(availableAnim.name, true);

		char.debugMode = true;
		char.setPosition(char.characterData.offsetX + OFFSET_X + 100, char.characterData.offsetY);

		charLayer.add(ghostChar);
		charLayer.add(char);

		animAtlas = (char.animateAtlas != null ? char.animateAtlas : null);

		currentChar.text = 'Character: ${char.curCharacter}';
		healthBarBG.color = charData.iconColor;
		reloadIcon();
		

		trace(charData.iconColor);

		updateCharPos(charData.offsetX, charData.offsetY);
		updatePointerPos();
		mixDataToChar(char, charData);
		mixDataToChar(ghostChar, charData);
	}

	function mixDataToChar(target:Character, data:CharacterData)
	{
		var sprite = (target.xml.has.sprite ? target.xml.att.sprite : target.curCharacter);
		if (data.sprite != sprite)
			target.loadSprite(Paths.image('characters/${data.sprite}'));
		target.icon = data.icon;
		target.flipX = !!data.flipX;
		target.antialiasing = data.antialiasing;
		target.isPlayer = data.isPlayer;
		target.playerOffsets = data.isPlayer;
		target.isGF = data.isGF;
		target.scale.set(data.scale, data.scale);
		target.holdTime = data.holdTime;
		target.fixChar(true);
		target.updateHitbox();
	}

	function loadChar(isOpponent:Bool)
	{
		var i:Int = charLayer.members.length - 1;
		while (i >= 0)
		{
			var memb:Character = charLayer.members[i];
			if (memb != null)
			{
				memb.kill();
				charLayer.remove(memb);
				memb.destroy();
			}
			--i;
		}
		charLayer.clear();
		ghostChar = new Character(0, 0, curChar, !isOpponent);
		ghostChar.debugMode = true;
		ghostChar.alpha = 0.6;

		char = new Character(0, 0, curChar, !isOpponent);
		char.debugMode = true;
		char.setPosition(char.characterData.offsetX + OFFSET_X + 100, char.characterData.offsetY);

		charLayer.add(ghostChar);
		charLayer.add(char);

		var charData = char.characterData;
		animAtlas = (char.animateAtlas != null ? char.animateAtlas : null);
		updateCharPos(charData.offsetX, charData.offsetY);
		resortAnims(char.characterData.animations);
		curAnim = getAnimIndex("idle");
		char.playAnim(charData.animations[getAnimIndex("idle")].name, true);
		ghostChar.characterData.animations = char.characterData.animations;

		char.updateHitbox();
		ghostChar.updateHitbox();
		updatePointerPos();
	}

	function loadUI()
	{
		topMenu = [
			{
				label: "File",
				childs: [
					{
						label: "New",
						onSelect: new_character
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
						label: "Exit",
						keybind: [ESCAPE],
						onSelect: _file_exit
					}
				]
			},
			{
				label: "Edit",
				childs: [
					{
						label: "Camera Position",
						onSelect: moveCameraPos
					},
					{
						label: "Properties",
						onSelect: edit_properties_window,
					}
				]
			},
			{
				label: "Animation",
				childs: [
					{
						label: "New Animation",
						keybind: [CONTROL, N],
						onSelect: add_anim_window,
					},
					null,
					{
						label: "Update Animation",
						keybind: [CONTROL, U],
						onSelect: update_anim_window,
					},
					null,
					{
						label: "Remove Animation",
						keybind: [CONTROL, D],
						onSelect: remove_anim_window,
					},
				]
			},
			{
				label: "Help",
				childs: [
					{
						label: "Controls",
						onSelect: help_controls_window
					}
				]
			}
		];

		topMenuSpr = new UITopMenu(topMenu);
		topMenuSpr.cameras = uiGroup.cameras = [uiCamera];

		Framerate.fpsCounter.alpha = 0.4;
		Framerate.memoryCounter.alpha = 0.4;
		Framerate.codenameBuildField.alpha = 0.4;
	}

	var ofs_cross:FlxSpriteGroup = new FlxSpriteGroup(0, 0);

	public function loadCross()
	{
		var i:Int = ofs_cross.members.length - 1;
		while (i >= 0)
		{
			var memb:FlxSprite = ofs_cross.members[i];
			if (memb != null)
			{
				memb.kill();
				ofs_cross.remove(memb);
				memb.destroy();
			}
			--i;
		}
		ofs_cross.clear();


		var x = -800;

		var horizontal_cross = new FlxSprite(x, -70).makeSolid(2000, 5);
		var vertical_cross = new FlxSprite(x, 0).makeSolid(5, 2000);
		horizontal_cross.y += (vertical_cross.height / 2);
		vertical_cross.x += (horizontal_cross.width / 2);
		ofs_cross.add(horizontal_cross);
		ofs_cross.add(vertical_cross);
		horizontal_cross.scrollFactor.set(1, 1);
		vertical_cross.scrollFactor.set(1, 1);
		// ofs_cross.screenCenter();
		ofs_cross.y = -200;
		ofs_cross.scrollFactor.set(1, 1);
		ofs_cross.alpha = 0.6;
	}

	var OFFSET_X:Float = 150;

	public function reloadStage()
	{
		var i:Int = stage.members.length - 1;
		while (i >= 0)
		{
			var memb:FunkinSprite = stage.members[i];
			if (memb != null)
			{
				memb.kill();
				stage.remove(memb);
				memb.destroy();
			}
			--i;
		}
		stage.clear();
		var playerXDifference = 0;
		if (char.isPlayer)
			playerXDifference = 670;

		var bg = new FunkinSprite(-600 + OFFSET_X - playerXDifference, -200, Paths.image("stages/default/stageback"));
		stage.add(bg);
		bg.scrollFactor.set(0.9, 0.9);

		var stageFront = new FunkinSprite(-600 + OFFSET_X - playerXDifference, 600, Paths.image("stages/default/stagefront"));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stage.add(stageFront);
		stageFront.scrollFactor.set(0.9, 0.9);

		stage.setPosition(0, 0);
	}

	function hasAtlas():Bool
		return (animAtlas != null);

	var movingCam:Bool = false;
	var movingCamDefaultPos:FlxPoint = null;
	var movingCamDefaultPosCam:FlxPoint = null;

	public function moveCameraPos(_)
	{
		movingCam = true;
		movingCamText.visible = true;
		updatePointerPos();
	}

	public function detectCamClick()
	{
		var charData = char.characterData;

		if (movingCam)
		{
			if (FlxG.mouse.justPressed)
			{
				var midx = char.getMidpoint().x;
				var midy = char.getMidpoint().y;

				var pos = FlxG.mouse.getWorldPosition(editorCamera);
				var placedPos:FlxPoint = new FlxPoint((!char.isPlayer ? pos.x + -(midx) : pos.x + -(midx)), -(pos.y - midy));

				movingCam = false;
				movingCamText.visible = false;
				charData.camOffsetX = placedPos.x;
				charData.camOffsetY = placedPos.y;
				updatePointerPos();
			}
		}
	}

	function updatePointerPos()
	{
		var x:Float = char.getMidpoint().x;
		var y:Float = char.getMidpoint().y;
		/*if (!char.isPlayer)
			{ */
		x += char.characterData.camOffsetX;
		/*}
			else
			{
				x -= char.characterData.camOffsetX;
		}*/
		y -= char.characterData.camOffsetY;

		x -= cameraPointer.width / 2;
		y -= cameraPointer.height / 2;
		cameraPointer.setPosition(x, y);
	}

	var movingOffset:Bool = false;
	var dragX:Float = -1;
	var dragY:Float = -1;

	public function moveCharPos()
	{
		var charSprite = (hasAtlas() ? char.animateAtlas : char);
		var charData = char.characterData;
		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(charSprite))
		{
			var pos = FlxG.mouse.getWorldPosition(FlxG.camera);
			dragX = charData.offsetX - pos.x;
			dragY = charData.offsetY - pos.y;
			movingOffset = true;
		}
		else if (!FlxG.mouse.overlaps(charSprite))
			movingOffset = false;

		if (movingOffset && FlxG.mouse.pressed)
		{
			var pos = FlxG.mouse.getWorldPosition(editorCamera);
			updateCharPos((pos.x + dragX), (pos.y + dragY));
		}
	}

	public function updateCharPos(x:Float, y:Float)
	{
		char.characterData.offsetX = x;
		char.characterData.offsetY = y;
		char.x = x;
		char.y = y;
		updatePointerPos();
	}

	public function reloadGhost()
	{
		ghostChar.loadSprite(char.characterData.sprite);
		for (i in 0...char.characterData.animations.length - 1)
		{
			XMLUtil.addAnimToSprite(ghostChar, char.characterData.animations[i]);
		}

		char.alpha = 0.85;
		ghostChar.visible = true;
		/*if (ghostDropDown.selectedLabel == '')
			{
				ghostChar.visible = false;
				char.alpha = 1;
		}*/
		ghostChar.color = 0xFF666688;
		ghostChar.antialiasing = char.antialiasing;
		ghostChar.playAnim(char.characterData.animations[curAnim].name, true);
	}

	public function mouseControl()
		{
			if (FlxG.mouse.justReleasedRight) {
				closeCurrentContextMenu();
				openContextMenu(topMenu[1].childs);
			}

			if (FlxG.mouse.wheel != 0) {
				camZoom += (FlxG.mouse.wheel / 10);
			}
		}

	function controlCharacter()
	{
		var controlArray:Array<Bool> = [
			FlxG.keys.justPressed.LEFT,
			FlxG.keys.justPressed.RIGHT,
			FlxG.keys.justPressed.UP,
			FlxG.keys.justPressed.DOWN
		];
		var holdShift = FlxG.keys.pressed.SHIFT;
		var holdAlt = FlxG.keys.pressed.ALT;

		for (i in 0...controlArray.length)
		{
			if (controlArray[i])
			{
				var multiplier:Float = 1;
				if (holdShift)
					multiplier = 10;
				if (holdAlt)
					multiplier = 0.1;

				var negaMult:Int = 1;
				if (i % 2 == 1)
					negaMult = -1;

				// For Player Offsets
				if (i == 1 && char.playerOffsets)
					negaMult = -1;
				if (i == 0 && char.playerOffsets)
					negaMult = 1;

				if (i > 1)
				{
					char.characterData.animations[curAnim].y += negaMult * multiplier;
					ghostChar.characterData.animations[curAnim].y += negaMult * multiplier;
				}
				else
				{
					char.characterData.animations[curAnim].x += negaMult * multiplier;
					ghostChar.characterData.animations[curAnim].x += negaMult * multiplier;
				}

				char.animOffsets.set(char.characterData.animations[curAnim].name,
					new FlxPoint(char.characterData.animations[curAnim].x, char.characterData.animations[curAnim].y));
				ghostChar.animOffsets.set(char.characterData.animations[curAnim].name,
					new FlxPoint(char.characterData.animations[curAnim].x, char.characterData.animations[curAnim].y));

				char.addOffset(char.characterData.animations[curAnim].anim, char.characterData.animations[curAnim].x,
					char.characterData.animations[curAnim].y);
				ghostChar.addOffset(char.characterData.animations[curAnim].anim, char.characterData.animations[curAnim].x,
					char.characterData.animations[curAnim].y);
				/*ghostChar.animOffsets.set(char.animation.curAnim.name,
					new FlxPoint(char.characterData.animations[curAnim].x, char.characterData.animations[curAnim].y)); */

				char.playAnim(char.characterData.animations[curAnim].name, false);
				if (char.getAnimName() != null && char.getAnimName() == ghostChar.getAnimName())
				{
					ghostChar.playAnim(char.getAnimName(), false);
				}
			}
		}
	}

	function controlCamera(elapsed:Float)
	{
		var ofs:Float = 500 * elapsed;
		var shift:Bool = (FlxG.keys.pressed.SHIFT);
		var cam_up:Bool = (FlxG.keys.pressed.W);
		var cam_down:Bool = (FlxG.keys.pressed.S);
		var cam_left:Bool = (FlxG.keys.pressed.A);
		var cam_right:Bool = (FlxG.keys.pressed.D);
		var cam_zoomers:Array<Bool> = [FlxG.keys.pressed.I, FlxG.keys.pressed.O];

		if (shift)
			ofs *= 4;

		if (cam_up)
			camFollow.y -= ofs;
		if (cam_down)
			camFollow.y += ofs;
		if (cam_left)
			camFollow.x -= ofs;
		if (cam_right)
			camFollow.x += ofs;

		var zoom_ofs = FlxG.camera.zoom * elapsed;
		if (cam_zoomers[0] && camZoom < 3)
		{
			camZoom += zoom_ofs;
			if (camZoom > 3)
				camZoom = 3;
		}
		if (cam_zoomers[1] && camZoom > 0.1)
		{
			camZoom -= zoom_ofs;
			if (camZoom < 0.1)
				camZoom = 0.1;
		}



		
	}

	function changeAnim()
	{
		var space = (FlxG.keys.justPressed.SPACE);
		var forward = (FlxG.keys.justPressed.L);
		var backwards = (FlxG.keys.justPressed.K);

		if (forward || backwards)
		{
			var changeLimit = char.characterData.animations.length;
			curAnim = FlxMath.wrap(curAnim + (forward ? 1 : -1), 0, changeLimit-1);

			trace(curAnim);
			trace(char.characterData.animations[curAnim]);

			char.playAnim(char.characterData.animations[curAnim].name, false);
			playingAnim.text = 'Animation: ${char.characterData.animations[curAnim].name}';
		}

		if (space)
			char.playAnim(char.characterData.animations[curAnim].name, true);

		char.updateHitbox();
		ghostChar.updateHitbox();
	}

	// Animation Windows
	function add_anim_window(_)
		openSubState(new AddAnimScreen(char, ghostChar, this));

	function update_anim_window(_)
		openSubState(new SelectAnimUpdate(char, ghostChar, this));

	function remove_anim_window(_)
		openSubState(new DeleteAnimScreen(char, ghostChar, this));

	function help_controls_window(_)
		openSubState(new HelpControls());

	function _file_exit(_)
	{
		FlxG.switchState(new CharacterSelection());
	}

	override function destroy() {
		Framerate.fpsCounter.alpha = 1;
		Framerate.memoryCounter.alpha = 1;
		Framerate.codenameBuildField.alpha = 1;
		super.destroy();
	}

	function new_character(_)
		FlxG.state.openSubState(new NewCharacter(char, ghostChar, this));


	function edit_properties_window(_)
		FlxG.state.openSubState(new CharacterProperties(char, ghostChar, this));

	function _file_save(_)
	{
		#if sys
		var assetPath = Paths.character(char.curCharacter);
		var path = Assets.getPath(assetPath);
		saveTo(path);
		return;
		#end
		_file_saveas(_);
	}

	function _file_saveas(_)
	{
		var xml = CharacterConfig.dataToXml(char.characterData);
		openSubState(new SaveSubstate(CharacterConfig.generateCharXML(xml.x), {
			defaultSaveFile: '${char.curCharacter}.xml'
		}));
	}

	#if sys
	function saveTo(path:String)
	{
		var xml = CharacterConfig.dataToXml(char.characterData);
		CharacterConfig.save(path, CharacterConfig.generateCharXML(xml.x));
	}
	#end

	function set_camZoom(value:Float):Float
	{
		editorCamera.zoom = value;
		return camZoom = value;
	}
}
