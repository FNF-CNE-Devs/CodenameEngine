package funkin.editors.ui;

import funkin.editors.ui.UIContextMenu.UIContextMenuOption;

class UITopMenu extends UISliceSprite {
	var options:Array<UIContextMenuOption>;
	public function new(options:Array<UIContextMenuOption>) {
		this.options = options;
		super(0, 0, FlxG.width, 25, 'editors/ui/topmenu');
		scrollFactor.set(0, 0);

		var x:Int = 0;
		for(o in options) {
			var b = new UITopMenuButton(x, 0, this, o.label, o.childs);
			x += b.bWidth;
			members.push(b);
		}
	}

	public var anyMenuOpened:Bool = false;

	public override function update(elapsed:Float) {
		anyMenuOpened = false;
		for(c in members) if (cast(c, UITopMenuButton).curMenu.contextMenuOpened()) {
			anyMenuOpened = true;
			break;
		}

		super.update(elapsed);

		bWidth = FlxG.width;
	}
}

class UITopMenuButton extends UISliceSprite {
	public var label:UIText;
	public var contextMenu:Array<UIContextMenuOption>;
	public var parent:UITopMenu;

	public var curMenu:UIContextMenu = null;

	public function new(x:Float, y:Float, parent:UITopMenu, label:String, contextMenu:Array<UIContextMenuOption>) {
		super(x, y, 0, 23, "editors/ui/menu-item");
		this.contextMenu = contextMenu;
		this.parent = parent;
		cursor = BUTTON;

		this.label = new UIText(4, 0, 0, label);
		this.label.alignment = CENTER;
		bWidth = Std.int(this.label.fieldWidth = this.label.frameWidth + 8);
		members.push(this.label);
	}

	public override function update(elapsed:Float) {
		label.follow(this, 0, Std.int((bHeight - label.height) / 2));
		super.update(elapsed);

		var opened = curMenu.contextMenuOpened();
		alpha = (hovered || opened) ? 1 : 0;
		framesOffset = opened ? 9 : 0;
	}

	public override function onHovered() {
		super.onHovered();
		if (curMenu.contextMenuOpened()) {
			UIState.state.curContextMenu.preventOutOfBoxClickDeletion();
		} else {
			if ((parent != null && parent.anyMenuOpened) || FlxG.mouse.justReleased) {
				openContextMenu();
			}
		}
	}

	public function openContextMenu() {
		var screenPos = getScreenPosition(null, __lastDrawCameras[0] == null ? FlxG.camera : __lastDrawCameras[0]);
		curMenu = UIState.state.openContextMenu(contextMenu, null, screenPos.x, screenPos.y + bHeight);
	}
}