package funkin.editors.charter;

import funkin.backend.chart.EventsData;
import funkin.game.Character;
import funkin.editors.ui.UIContextMenu.UIContextMenuOption;
import funkin.editors.ui.UITopMenu.UITopMenuButton;
import funkin.game.HealthIcon;
import funkin.backend.chart.ChartData.ChartStrumLine;

class CharterStrumline extends UISprite {
	public var strumLine:ChartStrumLine;
	public var hitsounds:Bool = true;

	public var draggingSprite:UISprite;
	public var healthIcon:HealthIcon;
	public var button:CharterStrumlineButton;

	public var draggable:Bool = false;
	public var dragging:Bool = false;

	public var curMenu:UIContextMenu = null;

	public function new(strumLine:ChartStrumLine) {
		super();
		this.strumLine = strumLine;

		scrollFactor.set(1, 0);
		alpha = 0;

		var icon = Character.getIconFromCharName(strumLine.characters != null ? strumLine.characters[0] : null);

		healthIcon = new HealthIcon(icon);
		healthIcon.scale.set((80 - (draggable ? 21 : 0)) / 150, (80 - (draggable ? 21 : 0)) / 150);
		healthIcon.updateHitbox();
		healthIcon.y = draggable ? 29 : 7;

		if(strumLine.visible == null) strumLine.visible = true;
		healthIcon.alpha = strumLine.visible ? 1 : 0.4;

		members.push(healthIcon);

		draggingSprite = new UISprite();
		draggingSprite.loadGraphic(Paths.image("editors/charter/drag-strumline"));
		draggingSprite.alpha = 0.4;
		draggingSprite.y = 9;
		draggingSprite.antialiasing = true;
		draggingSprite.cursor = BUTTON;
		members.push(draggingSprite);

		button = new CharterStrumlineButton(this);
		members.push(button);
	}

	public override function update(elapsed:Float) {
		if (FlxG.keys.justPressed.K) draggable = !draggable;
		if (healthIcon != null) {
			var healthScale:Float = FlxMath.lerp(healthIcon.scale.x, (80 - (draggable ? 21 : 0)) / 150, 1/20);
			healthIcon.scale.set(healthScale, healthScale);
			healthIcon.updateHitbox();

			healthIcon.follow(this, ((40 * 4) - healthIcon.width) / 2, FlxMath.lerp(healthIcon.y - y, draggable ? 29 : 7, 1/20));
		}

		var dragScale:Float = FlxMath.lerp(draggingSprite.scale.x, draggable ? 1 : 0.8, 1/16);
		draggingSprite.scale.set(dragScale, dragScale);
		draggingSprite.updateHitbox();

		draggingSprite.follow(this, (160/2) - (draggingSprite.width/2), FlxMath.lerp(draggingSprite.y - y, draggable ? 9 : 6, 1/12));
		draggingSprite.alpha = FlxMath.lerp(draggingSprite.alpha, draggable ? 0.4 : 0, 1/12);
		button.follow(this, 0, 95);

		draggingSprite.selectable = draggable;

		UIState.state.updateSpriteRect(draggingSprite);
		super.update(elapsed);
	}

	public function updateInfo() {
		members.remove(healthIcon);
		healthIcon.destroy();

		var icon = Character.getIconFromCharName(strumLine.characters != null ? strumLine.characters[0] : null);

		healthIcon = new HealthIcon(icon);
		healthIcon.scale.set((80 - (draggable ? 21 : 0)) / 150, (80 - (draggable ? 21 : 0)) / 150);
		healthIcon.updateHitbox();
		healthIcon.y = draggable ? 29 : 7;

		healthIcon.alpha = strumLine.visible ? 1 : 0.4;
		members.push(healthIcon);
	}
}

class CharterStrumlineButton extends UITopMenuButton {
	var strLine:CharterStrumline;
	public function new(parent:CharterStrumline) {
		super(0, 95, null, "Options", []);
		strLine = parent;
		bWidth = 40 * 4;
		this.label.fieldWidth = bWidth;
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		alpha = FlxMath.lerp(1/20, 1, alpha); // so that instead of 0% it is 33% visible
	}

	public override function openContextMenu() {
		contextMenu = [
			{
				label: "Visible",
				onSelect: function(_) {
					strLine.strumLine.visible = !strLine.strumLine.visible;
					strLine.healthIcon.alpha = strLine.strumLine.visible ? 1 : 0.4;
				},
				icon: strLine.strumLine.visible ? 1 : 0
			},
			null,
			{
				label: "Hitsounds",
				onSelect: function(_) {
					strLine.hitsounds = !strLine.hitsounds;
				},
				icon: strLine.hitsounds ? 1 : 0
			},
			null,
			{
				label: "Edit",
				onSelect: function (_) {
					Charter.instance.editStrumline(strLine.strumLine);
				}
			},
			{
				label: "Delete",
				onSelect: function (_) {
					Charter.instance.deleteStrumlineFromData(strLine.strumLine);
				}
			}
		];
		super.openContextMenu();
	}
}