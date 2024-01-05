package funkin.editors.character;

import flixel.util.FlxColor;
import flixel.math.FlxPoint;

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
		autoAlpha = false;

		ghostButton = new UIButton(x+282+17, y, "", function () {
			CharacterEditor.instance.ghostAnim(this.anim);
		}, 32);
		ghostButton.autoAlpha = false;
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
		editButton.frames = Paths.getFrames("editors/ui/grayscale-button");
		editButton.color = FlxColor.YELLOW;
		editButton.autoAlpha = false;
		members.push(editButton);

		editIcon = new FlxSprite(editButton.x + 8, editButton.y + 8).loadGraphic(Paths.image('editors/character/edit-button'));
		editIcon.antialiasing = false;
		members.push(editIcon);

		deleteButton = new UIButton(editButton.x+32+17, y, "", function () {
			CharacterEditor.instance.deleteAnim(this.anim);
		}, 32);
		deleteButton.color = FlxColor.RED;
		deleteButton.autoAlpha = false;
		members.push(deleteButton);

		deleteIcon = new FlxSprite(deleteButton.x + (15/2), deleteButton.y + 8).loadGraphic(Paths.image('editors/delete-button'));
		deleteIcon.antialiasing = false;
		members.push(deleteIcon);
	}

	public override function update(elapsed:Float) {
		editButton.selectable = ghostButton.selectable = deleteButton.selectable = selectable;
		editButton.shouldPress = ghostButton.shouldPress = deleteButton.shouldPress = shouldPress;

		hovered = !deleteButton.hovered;
		updatePos();
		super.update(elapsed);
	}

	public function updateInfo(anim:String, offset:FlxPoint, ghost:Bool) {
		this.anim = anim;

		field.text = '$anim (${offset.x}, ${offset.y})';
		ghostIcon.animation.play(ghost ? "alive" : "dead");
		ghostIcon.alpha = ghost ? 1 : 0.5;
	}

	public inline function updatePos() {
		// buttons
		deleteButton.x = (editButton.x = (ghostButton.x = (x+282+17))+32+17)+32+17;
		deleteButton.y = editButton.y = ghostButton.y = y;
		// icons
		ghostIcon.x = ghostButton.x + 8; ghostIcon.y = ghostButton.y + 8;
		editIcon.x = editButton.x + 8; editIcon.y = editButton.y + 8;
		deleteIcon.x = deleteButton.x + (15/2); deleteIcon.y = deleteButton.y + 8;
	}
}