package funkin.editors.charter;

class CharterQauntButton extends funkin.editors.ui.UITopMenu.UITopButton {
	public var qaunt:Int = 0;

	public function new(x:Float, y:Float, qaunt:Int) {
		super(x, y, Std.string(qaunt));
		this.qaunt = qaunt;
	}
}