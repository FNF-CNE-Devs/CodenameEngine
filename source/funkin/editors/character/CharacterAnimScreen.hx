package funkin.editors.character;

import flixel.math.FlxPoint;
import flixel.animation.FlxAnimation;
import funkin.backend.utils.XMLUtil.AnimData;

class CharacterAnimScreen extends UISubstateWindow {
	public var animName:Null<String>;
	public var animData:AnimData;

	public var saveButton:UIButton;
	public var closeButton:UIButton;

	private var onSave:(animData:AnimData) -> Void = null;

	public function new(animName:Null<String>, animData:AnimData) {
		this.animName = animName;
		super();
	}

	public override function create() {
		var creatingAnim:Bool = animName == null;

		if (creatingAnim) {
			animName = "";
		}

		winTitle = creatingAnim ? 'Creating Animation' : 'Animation $animName properties';
		winWidth = 690; winHeight = 334;

		super.create();

		function addLabelOn(ui:UISprite, text:String)
			add(new UIText(ui.x, ui.y - 24, 0, text));

		var title:UIText;
		add(title = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, creatingAnim ? "Create New Animation" : "Edit Animation Properties", 28));

		saveButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, "Save & Close", function() {
			// saveStrumline();
			close();
		}, 125);
		add(saveButton);

		closeButton = new UIButton(saveButton.x - 20, saveButton.y, creatingAnim ? "Cancel" : "Close", function() {
			if (creatingAnim) onSave(null);
			close();
		}, 125);
		add(closeButton);
		closeButton.x -= closeButton.bWidth;
	}
}