package funkin.options.type;

import flixel.math.FlxPoint;

@:allow()
class Checkbox extends TextOption {

	public var checkbox:FlxSprite;
	public var checked:Bool;

	public var parent:Dynamic;

	private function get_selected() {

	}
	public var optionName:String;

	private var offsets:Map<String, FlxPoint> = [
		"checked" => FlxPoint.get(1, -1),
		"unchecked" => FlxPoint.get(-12, -72),
		"checking" => FlxPoint.get(12, 30)
	];
	private var baseCheckboxOffset:FlxPoint = FlxPoint.get();

	public function new(text:String, desc:String, optionName:String, ?parent:Dynamic) {
		super(text, desc, null);

		if (parent == null)
			parent = Options;

		this.parent = parent;

		checkbox = new FlxSprite(10, -40);
		checkbox.frames = Paths.getFrames('menus/options/checkboxThingie');
		checkbox.animation.addByPrefix("checked", "Check Box Selected Static", 24);
		checkbox.animation.addByPrefix("unchecked", "Check Box unselected", 24);
		checkbox.animation.addByPrefix("checking", "Check Box selecting animation", 24, false);
		checkbox.antialiasing = true;
		checkbox.scale.set(0.75, 0.75);
		checkbox.updateHitbox();
		add(checkbox);

		baseCheckboxOffset.set(checkbox.offset.x, checkbox.offset.y);

		this.optionName = optionName;
		checked = Reflect.field(parent, optionName);
	}

	public override function update(elapsed:Float) {
		if (checkbox.animation.curAnim == null || (checkbox.animation.curAnim.finished || (checkbox.animation.curAnim.reversed && checkbox.animation.curAnim.curFrame <= 0))) {
			checkbox.animation.play(checked ? "checked" : "unchecked", true);
		}
		super.update(elapsed);
		var offset = offsets[checkbox.animation.curAnim.name];
		if (offset != null)
			checkbox.offset.set(
				(offset.x * checkbox.scale.x) + baseCheckboxOffset.x,
				(offset.y * checkbox.scale.y) + baseCheckboxOffset.y);
	}

	public override function onSelect() {
		Reflect.setField(parent, optionName, checked = !checked);
		checkbox.animation.play("checking", true, !checked);
	}

	public override function destroy() {
		super.destroy();
		for(e in offsets) e.put();
		baseCheckboxOffset.put();
	}
}