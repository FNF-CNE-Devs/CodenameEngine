package funkin.options;

class OptionsTree extends FlxTypedGroup<OptionsScreen> {
	public var lastMenu:OptionsScreen;
	public var treeParent:TreeMenu;
	//public override function new() {
	//	super();
	//}

	public override function update(elapsed:Float) {
		var last = members.last();
		if (last != null)
			last.update(elapsed);
	}


	public override function draw() {
		super.draw();
		if (lastMenu != null) {
			lastMenu.draw();
		}
	}

	public override function add(m:OptionsScreen) {
		super.add(m);
		setup(m);
		clearLastMenu();
		onMenuChange();
		return m;
	}
	public override function insert(pos:Int, m:OptionsScreen) {
		var last = members.last();
		super.insert(pos, m);
		setup(m);
		if (last != members.last())
			onMenuChange();
		return m;
	}

	public function setup(m:OptionsScreen) {
		m.onClose = __subMenuClose;
		m.id = members.indexOf(m);
		m.parent = this;
		m.update(0);
	}

	function __subMenuClose(m:OptionsScreen) {
		clearLastMenu();
		lastMenu = m;
		remove(m, true);
		onMenuChange();
		onMenuClose(m);
	}

	public function clearLastMenu() {
		if (lastMenu != null) {
			lastMenu.destroy();
			lastMenu = null;
		}
	}

	public override function destroy() {
		super.destroy();
		lastMenu = FlxDestroyUtil.destroy(lastMenu);
	}

	public dynamic function onMenuChange() {

	}

	public dynamic function onMenuClose(m:OptionsScreen) {
	}
}