package funkin.editors.charter;

class CharterQuantButton extends funkin.editors.ui.UITopMenu.UITopButton {
	public var quant:Int = 0;
	public function new(x:Float, y:Float, quant:Int) {
		super(x, y, Std.string(quant));
		this.quant = quant;
	}
}