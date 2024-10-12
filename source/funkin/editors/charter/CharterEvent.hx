package funkin.editors.charter;

import flixel.group.FlxSpriteGroup;
import funkin.editors.charter.Charter.ICharterSelectable;
import flixel.math.FlxPoint;
import funkin.game.Character;
import funkin.game.HealthIcon;
import funkin.editors.charter.CharterBackdropGroup.EventBackdrop;
import funkin.backend.chart.ChartData.ChartEvent;

class CharterEvent extends UISliceSprite implements ICharterSelectable {
	public var events:Array<ChartEvent>;
	public var step:Float;
	public var icons:Array<FlxSprite> = [];

	public var selected:Bool = false;
	public var draggable:Bool = true;

	public var eventsBackdrop:EventBackdrop;
	public var snappedToGrid:Bool = true;

	public function new(step:Float, ?events:Array<ChartEvent>) {
		super(-100, (step * 40) - 17, 100, 34, 'editors/charter/event-spr');
		this.step = step;
		this.events = events.getDefault([]);

		cursor = BUTTON;
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (snappedToGrid && eventsBackdrop != null)
			x = eventsBackdrop.x + eventsBackdrop.width - (bWidth = 37 + (icons.length * 22));

		for(k=>i in icons) {
			i.follow(this, (k * 22) + 30 - (i.width / 2), (bHeight - i.height) / 2);
		}

		colorTransform.redMultiplier = colorTransform.greenMultiplier = colorTransform.blueMultiplier = selected ? 0.75 : 1;
		colorTransform.redOffset = colorTransform.greenOffset = selected ? 96 : 0;
		colorTransform.blueOffset = selected ? 168 : 0;

		for (sprite in icons)
			sprite.colorTransform = colorTransform;
	}

	private static function generateDefaultIcon(name:String) {
		var isBase64:Bool = false;
		var path:String = Paths.image('editors/charter/event-icons/$name');
		if (!Assets.exists(path)) path = Paths.image('editors/charter/event-icons/Unknown');
		if (Assets.exists(Paths.pack('events/$name'))) {
			var packimg = Assets.getText(Paths.pack('events/$name')).split('________PACKSEP________')[3];
			if (isBase64 = (packimg != null))
				path = Assets.getText(Paths.pack('events/$name')).split('________PACKSEP________')[3];
		}
		var spr = new FlxSprite().loadGraphic(isBase64 ? openfl.display.BitmapData.fromBase64(path.trim(), 'UTF8') : path);
		return spr;
	}

	public static function generateEventIcon(event:ChartEvent):FlxSprite {
		switch(event.name) {
			case "Time Signature Change":
				if(event.params != null && (event.params[0] >= 0 || event.params[1] >= 0)) {
					var group = new FlxSpriteGroup();
					group.add(generateDefaultIcon(event.name));
					group.add({ // top
						var num = new EventNumber(9, -1, event.params[0], EventNumber.ALIGN_CENTER);
						num.scrollFactor.set(1, 1);
						num.active = false;
						num;
					});
					group.add({ // bottom
						var num = new EventNumber(9, 10, event.params[1], EventNumber.ALIGN_CENTER);
						num.scrollFactor.set(1, 1);
						num.active = false;
						num;
					});
					return group;
				}
			case "Camera Movement":
				// custom icon for camera movement
				var state = cast(FlxG.state, Charter);
				if (event.params != null && event.params[0] != null && event.params[0] >= 0 && event.params[0] < state.strumLines.length) {
					// camera movement, use health icon
					var icon = Character.getIconFromCharName(state.strumLines.members[event.params[0]].strumLine.characters[0]);
					var healthIcon = new HealthIcon(icon);
					healthIcon.setUnstretchedGraphicSize(32, 32, false);
					healthIcon.scrollFactor.set(1, 1);
					healthIcon.active = false;
					return healthIcon;
				}
		}
		return generateDefaultIcon(event.name);
	}

	public override function onHovered() {
		super.onHovered();
		/*
		if (FlxG.mouse.justReleased)
			FlxG.state.openSubState(new CharterEventScreen(this));
		*/
	}

	public function handleSelection(selectionBox:UISliceSprite):Bool {
		return (selectionBox.x + selectionBox.bWidth > x) && (selectionBox.x < x + bWidth) && (selectionBox.y + selectionBox.bHeight > y) && (selectionBox.y < y + bHeight);
	}

	public function handleDrag(change:FlxPoint) {
		var newStep:Float = step = FlxMath.bound(step + change.x, 0, Charter.instance.__endStep-1);
		y = ((newStep) * 40) - 17;
	}

	public function refreshEventIcons() {
		while(icons.length > 0) {
			var i = icons.shift();
			members.remove(i);
			i.destroy();
		}

		for(event in events) {
			var spr = generateEventIcon(event);
			icons.push(spr);
			members.push(spr);
		}

		draggable = true;
		for (event in events)
			if (event.name == "BPM Change" || event.name == "Time Signature Change") {
				draggable = false;
				break;
			}

		x = (snappedToGrid && eventsBackdrop != null ? eventsBackdrop.x : 0) - (bWidth = 37 + (icons.length * 22));
	}
}

class EventNumber extends FlxSprite {
	public static inline final ALIGN_NORMAL:Int = 0;
	public static inline final ALIGN_CENTER:Int = 1;

	public var digits:Array<Int> = [];

	public var align:Int = ALIGN_NORMAL;

	public function new(x:Float, y:Float, number:Int, ?align:Int = ALIGN_NORMAL) {
		super(x, y);
		this.digits = [];
		this.align = align;
		while (number > 0) {
			this.digits.insert(0, number % 10);
			number = Std.int(number / 10);
		}
		loadGraphic(Paths.image('editors/charter/event-icons/components/eventNums'), true, 6, 7);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	override function draw() {
		var baseX = x;
		var offsetX = 0.0;
		if(align == ALIGN_CENTER) offsetX = -(digits.length - 1) * frameWidth * Math.abs(scale.x) / 2;

		x = baseX + offsetX;
		for (i in 0...digits.length) {
			frame = frames.frames[digits[i]];
			super.draw();
			x += frameWidth * Math.abs(scale.x);
		}
		x = baseX;
	}

	public var numWidth(get, never):Float;
	private function get_numWidth():Float {
		return Math.abs(scale.x) * frameWidth * digits.length;
	}
	public var numHeight(get, never):Float;
	private function get_numHeight():Float {
		return Math.abs(scale.y) * frameHeight;
	}

	public override function updateHitbox():Void {
		var numWidth = this.numWidth;
		var numHeight = this.numHeight;
		width = numWidth;
		height = numHeight;
		offset.set(-0.5 * (numWidth - frameWidth * digits.length), -0.5 * (numHeight - frameHeight));
		centerOrigin();
	}
}