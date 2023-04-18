package funkin.editors.charter;

import funkin.editors.ui.UIContextMenu.UIContextMenuOption;
import funkin.editors.ui.UITopMenu.UITopMenuButton;
import funkin.game.HealthIcon;
import funkin.backend.chart.ChartData.ChartStrumLine;

class CharterStrumline extends UISprite {
	public var strumLine:ChartStrumLine;
	public var hitsounds:Bool = true;

	var healthIcon:HealthIcon;
	var button:CharterStrumlineButton;

	public var curMenu:UIContextMenu = null;

	public function new(strumLine:ChartStrumLine) {
		super();
		this.strumLine = strumLine;

		scrollFactor.set(1, 0);
		alpha = 0;

		healthIcon = new HealthIcon(strumLine.characters != null ? strumLine.characters[0] : null);
		healthIcon.scale.set(80 / 150, 80 / 150);
		healthIcon.updateHitbox();

		members.push(healthIcon);

		button = new CharterStrumlineButton(this);

		members.push(button);
	}

	public override function update(elapsed:Float) {
		healthIcon.follow(this, ((40 * 4) - healthIcon.width) / 2, 0);
		button.follow(this, 0, 95);
		super.update(elapsed);
	}

	public function updateInfo() {
		// todo
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
				label: "Player",
				onSelect: function(_) {
					strLine.strumLine.type = PLAYER;
				},
				icon: strLine.strumLine.type == PLAYER ? 1 : 0
			},
			{
				label: "Opponent",
				onSelect: function(_) {
					strLine.strumLine.type = OPPONENT;
				},
				icon: strLine.strumLine.type == OPPONENT ? 1 : 0
			},
			{
				label: "Additional",
				onSelect: function(_) {
					strLine.strumLine.type = ADDITIONAL;
				},
				icon: strLine.strumLine.type == ADDITIONAL ? 1 : 0
			},
			null,
			{
				label: "Hitsounds",
				onSelect: function(_) {
					strLine.hitsounds = !strLine.hitsounds;
				},
				icon: strLine.hitsounds ? 1 : 0
			}
		];
		super.openContextMenu();
	}
}