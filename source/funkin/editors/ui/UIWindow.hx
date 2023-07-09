package funkin.editors.ui;

class UIWindow extends UISliceSprite {
	public var titleSpr:UIText;

	public override function new(x:Float, y:Float, w:Int, h:Int, title:String) {
		super(x, y, w, h,  "editors/ui/warning-popup");
		
		members.push(titleSpr = new UIText(x + 25, y, bWidth - 50, title, 15, -1));
		titleSpr.y = y + ((30 - titleSpr.height) / 2);
	}
}