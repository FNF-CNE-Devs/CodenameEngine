package funkin.editors.character;

import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import funkin.game.Character;

class CharacterAnimsWindow extends UIWindow {
	public var character:Character;

	public var buttons:FlxGroup = new FlxGroup();
	public var animButtons:Map<String, CharacterAnimButtons> = [];

	public var addButton:UIButton;
	public var addIcon:FlxSprite;

	public function new(character:Character) {
		super(800-23,140+23+46,450+23,511-23, "Character Animations");
		this.character = character;

		createButtons();
		buttons.cameras = [CharacterEditor.instance.animsCamera];
		members.push(buttons);
	}

	public function createButtons() {
		for (i=>anim in character.getNameList()) 
			createNewButton(anim, character.getAnimOffset(anim), false, -1, false);

		addButton = new UIButton(25, 16+((32+16)*(character.getNameList().length)), "", 
			function () {
				CharacterEditor.instance.createAnimWithUI();
			}
		, 426);
		addButton.cameras = [CharacterEditor.instance.animsCamera];
		addButton.color = FlxColor.GREEN;

		addIcon = new FlxSprite(addButton.x + (440/2) - 8, addButton.y + (32/2) - 8).loadGraphic(Paths.image('editors/charter/add-button'));
		addIcon.cameras = [CharacterEditor.instance.animsCamera];
		addIcon.antialiasing = false;
		addButton.members.push(addIcon);

		members.push(addButton);
		updateButtonsPos();
	}

	public function createNewButton(anim:String, offset:FlxPoint, ghost:Bool = false, id:Int = -1, ?updatePos:Bool = true) {
		var button = new CharacterAnimButtons(0,0, anim, offset);
		if (id == -1) buttons.add(button);
		else buttons.members.insert(id, button);
		animButtons.set(anim,button);

		if (updatePos)
			updateButtonsPos();
	}

	public function removeButton(anim:String) {
		var button:CharacterAnimButtons = animButtons.get(anim);
		buttons.members.remove(button);
		button.destroy();

		updateButtonsPos();
	}

	public function updateButtonsPos() {
		for (i => button in buttons.members)
			cast(button, CharacterAnimButtons).updatePos(23,16+((32+16)*i));

		addButton.y = 16+((32+16)*(buttons.members.length));
		addIcon.x = addButton.x + (440/2) - 8; addIcon.y = addButton.y + (32/2) - 8;
	}

	public inline function changeCurAnim(anim:String) {
		for (_anim => button in animButtons) 
			button.alpha = _anim == anim ? 1 : 0.25;
	}

	var scrollY:Float = 0;

	public override function update(elapsed:Float) {
		super.update(elapsed);

		__rect.x = x; __rect.y = y+23;
		__rect.width = bWidth; __rect.height = bHeight-23;
		if(UIState.state.isOverlapping(this, __rect)) {
			var nextscrollY = scrollY - FlxG.mouse.wheel * 12;
			if (nextscrollY >= 0 && nextscrollY + CharacterEditor.instance.animsCamera.height <= (addButton.y +32 +23))
				scrollY = nextscrollY;
			hovered = true;
		} else
			hovered = false;

		for (button in buttons.members)
			cast(button, UISprite).selectable = hovered;
		addButton.selectable = hovered;

		CharacterEditor.instance.animsCamera.scroll.y = FlxMath.lerp(CharacterEditor.instance.animsCamera.scroll.y, scrollY, 1/3);

		//addButtonIndicator.y = CharacterEditor.instance.animsCamera.height - addButtonIndicator.width + CharacterEditor.instance.animsCamera.scroll.y;
	}
}

class CharacterAnimButtons extends UIButton {
	public var anim:String = "";

	public var editButton:UIButton;
	public var editIcon:FlxSprite;

	public var ghostButton:UIButton;
	public var ghostIcon:FlxSprite;

	public var deleteButton:UIButton;
	public var deleteIcon:FlxSprite;

	public function new(x:Float,y:Float,anim:String, offset:FlxPoint) {
		this.anim = anim;
		super(x,y, '$anim (${offset.x}, ${offset.y})', function () {
			CharacterEditor.instance.playAnimation(this.anim);
		}, 282);

		ghostButton = new UIButton(x+282+17, y, "", function () {
			CharacterEditor.instance.ghostAnim(this.anim);
		}, 32);
		members.push(ghostButton);

		ghostIcon = new FlxSprite(ghostButton.x + 8, ghostButton.y + 8).loadGraphic(Paths.image('editors/character/ghost-button'), true, 16, 16);
		ghostIcon.animation.add("alive", [0]);
		ghostIcon.animation.add("dead", [1]);
		ghostIcon.animation.play("dead"); ghostIcon.alpha = 0.5;
		ghostIcon.antialiasing = false;
		ghostIcon.updateHitbox();
		members.push(ghostIcon);

		editButton = new UIButton(ghostButton.x+32+17, y, "", function () {
			CharacterEditor.instance.editAnimWithUI(this.anim);
		}, 32);
		members.push(editButton);

		editIcon = new FlxSprite(editButton.x + 8, editButton.y + 8).loadGraphic(Paths.image('editors/character/edit-button'));
		editIcon.antialiasing = false;
		members.push(editIcon);

		deleteButton = new UIButton(editButton.x+32+17, y, "", function () {
			CharacterEditor.instance.deleteAnim(this.anim);
		}, 32);
		deleteButton.color = FlxColor.RED;
		members.push(deleteButton);

		deleteIcon = new FlxSprite(deleteButton.x + (15/2), deleteButton.y + 8).loadGraphic(Paths.image('editors/character/delete-button'));
		deleteIcon.antialiasing = false;
		members.push(deleteIcon);
	}

	public override function update(elapsed:Float) {
		editButton.selectable = ghostButton.selectable = deleteButton.selectable = selectable;
		super.update(elapsed);
	}

	public function updateInfo(anim:String, offset:FlxPoint, ghost:Bool) {
		this.anim = anim;

		field.text = '$anim (${offset.x}, ${offset.y})';
		ghostIcon.animation.play(ghost ? "alive" : "dead");
		ghostIcon.alpha = ghost ? 1 : 0.5;
	}

	public inline function updatePos(x:Float, y:Float) {
		// buttons
		this.x = x; this.y = ghostButton.y = editButton.y = deleteButton.y = y;
		deleteButton.x = (editButton.x = (ghostButton.x = (x+282+17))+32+17)+32+17;
		// icons
		ghostIcon.x = ghostButton.x + 8; ghostIcon.y = ghostButton.y + 8;
		editIcon.x = editButton.x + 8; editIcon.y = editButton.y + 8;
		deleteIcon.x = deleteButton.x + (15/2); deleteIcon.y = deleteButton.y + 8;
	}
}