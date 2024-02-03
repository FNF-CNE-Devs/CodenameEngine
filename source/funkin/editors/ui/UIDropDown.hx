package funkin.editors.ui;

class UIDropDown extends UISliceSprite {
	public var dropButton:UIButton;
	public var label:UIText;

	public var index:Int = 0;
	public var options:Array<String>;

	public var onChange:Int->Void;

	var curMenu:UIContextMenu = null;

	public function new(x:Float, y:Float, width:Int = 320, height:Int = 32, options:Array<String>, index:Int = 0) {
		super(x, y, width - height, height, 'editors/ui/inputbox'); // using same sprite cause fuck you

		this.options = options;
		this.index = index;

		cursor = BUTTON;

		label = new UIText(0, 0, width - height, options[index]);
		members.push(label);

		dropButton = new UIButton(0, 0, "V", null, height, height);
		members.push(dropButton);
	}

	public function setOption(newIndex:Int) {
		if (index != (index = newIndex)) {
			label.text = options[index];
			if (onChange != null)
				onChange(index);
		}
	}

	public override function update(elapsed:Float) {
		var opened = curMenu.contextMenuOpened();
		framesOffset = (opened || (hovered && FlxG.mouse.pressed)) ? 18 : (hovered ? 9 : 0);
		if (FlxG.mouse.justReleased && (hovered || dropButton.hovered)) {
			if (opened)
				UIState.state.curContextMenu.preventOutOfBoxClickDeletion();
			else
				openContextMenu();
		}

		super.update(elapsed);

		label.follow(this, 4, Std.int((bHeight - label.height) / 2));
		dropButton.follow(this, bWidth - bHeight, 0);
	}

	public function openContextMenu() {
		var screenPos = getScreenPosition(null, __lastDrawCameras[0] == null ? FlxG.camera : __lastDrawCameras[0]);
		curMenu = UIState.state.openContextMenu([
			for(k=>o in options) {
				icon: (k == index) ? 1 : 0,
				label: o
			}
		], function(_, i, _) {
			setOption(i);
		}, __lastDrawCameras[0].x + screenPos.x, __lastDrawCameras[0].y + screenPos.y + bHeight);
	}
}