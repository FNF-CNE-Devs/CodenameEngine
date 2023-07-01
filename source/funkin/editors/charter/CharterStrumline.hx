package funkin.editors.charter;

import funkin.game.Character;
import funkin.editors.ui.UIContextMenu.UIContextMenuOption;
import funkin.editors.ui.UITopMenu.UITopMenuButton;
import funkin.game.HealthIcon;
import funkin.backend.chart.ChartData.ChartStrumLine;

class CharterStrumline extends UISprite {
	public var strumLine:ChartStrumLine;

	public var hitsounds:Bool = true;

	public var healthIcon:HealthIcon;
	public var button:CharterStrumlineButton;

	public var curMenu:UIContextMenu = null;

	public function new(strumLine:ChartStrumLine) {
		super();
		this.strumLine = strumLine;

		scrollFactor.set(1, 0);
		alpha = 0;

		var icon = Character.getIconFromCharName(strumLine.characters != null ? strumLine.characters[0] : null);

		healthIcon = new HealthIcon(icon);
		healthIcon.scale.set(80 / 150, 80 / 150);
		healthIcon.updateHitbox();
		if(strumLine.visible == null)
			strumLine.visible = true;
		healthIcon.alpha = strumLine.visible ? 1 : 0.4;

		members.push(healthIcon);

		button = new CharterStrumlineButton(this);
		members.push(button);
	}

	public override function update(elapsed:Float) {
		if (healthIcon != null)
			healthIcon.follow(this, ((40 * 4) - healthIcon.width) / 2, 0);
		button.follow(this, 0, 95);
		super.update(elapsed);
	}

	public function updateInfo() {
		members.remove(healthIcon);
		healthIcon.destroy();

		var icon = Character.getIconFromCharName(strumLine.characters != null ? strumLine.characters[0] : null);

		healthIcon = new HealthIcon(icon);
		healthIcon.scale.set(80 / 150, 80 / 150);
		healthIcon.updateHitbox();
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
		alpha = FlxMath.lerp(1/3, 1, alpha); // so that instead of 0% it is 33% visible
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