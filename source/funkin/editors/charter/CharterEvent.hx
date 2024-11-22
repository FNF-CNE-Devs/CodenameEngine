package funkin.editors.charter;

import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import funkin.backend.chart.ChartData.ChartEvent;
import funkin.backend.scripting.DummyScript;
import funkin.backend.scripting.Script;
import funkin.editors.charter.Charter.ICharterSelectable;
import funkin.editors.charter.CharterBackdropGroup.EventBackdrop;
import funkin.game.Character;
import funkin.game.HealthIcon;
import openfl.display.BitmapData;

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

	/**
	 * Pack data is a list of 4 strings separated by `________PACKSEP________`
	 * [0] Event Name
	 * [1] Event Script
	 * [2] Event JSON Info
	 * [3] Event Icon
	 * [4] Event UI Script / Icon Script
	**/
	@:dox(hide) public static function getPackData(name:String):Array<String> {
		var packFile = Paths.pack('events/${name}');
		if (Assets.exists(packFile)) {
			return Assets.getText(packFile).split('________PACKSEP________');
		}
		return null;
	}

	@:dox(hide) public static function getUIScript(event:ChartEvent, caller:String):Script {
		var uiScript = Paths.script('data/events/${event.name}.ui');
		var script:Script = null;
		if(Assets.exists(uiScript)) {
			script = Script.create(uiScript);
		} else {
			var packData = getPackData(event.name);
			if(packData != null) {
				var scriptFile = packData[4];
				if(scriptFile != null) {
					script = Script.fromString(scriptFile, uiScript);
				}
			}
		}

		if(script != null && !(script is DummyScript)) {
			// classes and functions
			script.set("EventIconGroup", EventIconGroup); // automatically imported
			script.set("EventNumber", EventNumber); // automatically imported
			script.set("getIconFromStrumline", getIconFromStrumline);
			script.set("getIconFromCharName", getIconFromCharName);
			script.set("generateDefaultIcon", generateDefaultIcon);
			script.set("getPackData", getPackData);
			script.set("getEventComponent", getEventComponent);
			// data
			script.set("event", event);
			script.set("caller", caller);

			script.load();
		}

		return script;
	}

	/**
	 * Generates the default event icon for the wanted event
	 * @param name The name of the event
	 * @return The icon
	**/
	private static function generateDefaultIcon(name:String) {
		var isBase64:Bool = false;
		var path:String = Paths.image('editors/charter/event-icons/$name');
		var defaultPath = Paths.image('editors/charter/event-icons/Unknown');
		if(!Assets.exists(path)) {
			path = defaultPath;

			var packData = getPackData(name);
			if(packData != null) {
				var packImg = packData[3];
				if(packImg != null && packImg.length > 0) {
					isBase64 = !packImg.startsWith("assets/");
					path = packImg;
				}
			}
		}
		path = path.trim();

		var graphic:FlxGraphicAsset = try {
			isBase64 ? openfl.display.BitmapData.fromBase64(path, 'UTF8') : path;
		} catch(e:Dynamic) {
			Logs.trace('Failed to load event icon: ${e.toString()}', ERROR);
			isBase64 = false;
			defaultPath;
		}

		if(!isBase64) {
			if (!Assets.exists(graphic))
				graphic = defaultPath;
		}

		return new FlxSprite().loadGraphic(graphic);
	}

	/**
	 * Gets a component sprite from the editors/charter/event-icons/components folder
	 * If you wanna use a number, please use the EventNumber class instead
	 * @param type The type of component to get
	 * @param x The x position of the sprite (optional)
	 * @param y The y position of the sprite (optional)
	 * @return The component sprite
	**/
	public static function getEventComponent(type:String, x:Float = 0.0, y:Float = 0.0) {
		var componentPath = Paths.image("editors/charter/event-icons/components/" + type);
		if(Assets.exists(componentPath))
			return new FlxSprite(x, y).loadGraphic(componentPath);

		Logs.trace('Could not find component $type', WARNING);
		return null;
	}

	/**
	 * Expected to be called from inside of a ui script,
	 * calling this elsewhere might cause unexpected results or crashes
	**/
	public static function getIconFromStrumline(index:Null<Int>) {
		var state = cast(FlxG.state, Charter);
		if (index != null && index >= 0 && index < state.strumLines.length) {
			return getIconFromCharName(state.strumLines.members[index].strumLine.characters[0]);
		}
		return null;
	}

	public static function getIconFromCharName(name:String) {
		var icon = Character.getIconFromCharName(name);
		var healthIcon = new HealthIcon(icon);
		CoolUtil.setUnstretchedGraphicSize(healthIcon, 32, 32, false);
		healthIcon.scrollFactor.set(1, 1);
		healthIcon.active = false;
		return healthIcon;
	}

	public static function generateEventIcon(event:ChartEvent):FlxSprite {
		var script = getUIScript(event, "event-icon");
		if(script != null && !(script is DummyScript)) {
			if(script.get("generateIcon") != null) {
				var res:FlxSprite = script.call("generateIcon");
				if(res != null)
					return res;
			}
		}

		switch(event.name) {
			case "Time Signature Change":
				if(event.params != null && (event.params[0] >= 0 || event.params[1] >= 0)) {
					var group = new EventIconGroup();
					group.add(generateDefaultIcon(event.name));
					group.add({ // top
						var num = new EventNumber(9, -1, event.params[0], EventNumber.ALIGN_CENTER);
						num.active = false;
						num;
					});
					group.add({ // bottom
						var num = new EventNumber(9, 10, event.params[1], EventNumber.ALIGN_CENTER);
						num.active = false;
						num;
					});
					return group;
				}
			case "Camera Movement":
				// camera movement, use health icon
				if(event.params != null) {
					var icon = getIconFromStrumline(event.params[0]);
					if(icon != null) return icon;
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

class EventIconGroup extends FlxSpriteGroup {
	public var forceWidth:Float = 32;
	public var forceHeight:Float = 32;
	public var dontTransformChildren:Bool = true;

	public function new() {
		super();
		scrollFactor.set(1, 1);
	}

	override function preAdd(sprite:FlxSprite):Void
	{
		super.preAdd(sprite);
		sprite.scrollFactor.set(1, 1);
	}

	public override function transformChildren<V>(Function:FlxSprite->V->Void, Value:V):Void
	{
		if (dontTransformChildren)
			return;

		super.transformChildren(Function, Value);
	}

	override function set_x(Value:Float):Float
	{
		if (exists && x != Value)
			transformChildren(xTransform, Value - x); // offset
		return x = Value;
	}

	override function set_y(Value:Float):Float
	{
		if (exists && y != Value)
			transformChildren(yTransform, Value - y); // offset
		return y = Value;
	}

	override function get_width() {
		return forceWidth;
	}
	override function get_height() {
		return forceHeight;
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