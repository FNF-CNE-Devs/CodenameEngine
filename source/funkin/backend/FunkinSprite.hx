package funkin.backend;

import flixel.animation.FlxAnimation;
import flxanimate.animate.FlxAnim.FlxSymbolAnimation;
import funkin.backend.utils.XMLUtil.BeatAnim;
import funkin.backend.utils.XMLUtil.AnimData;
import funkin.backend.utils.XMLUtil.IXMLEvents;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.addons.effects.FlxSkewedSprite;
import haxe.io.Path;
import funkin.backend.scripting.events.PlayAnimEvent.PlayAnimContext;
import funkin.backend.system.interfaces.IOffsetCompatible;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.util.typeLimit.OneOfTwo;
import funkin.backend.system.interfaces.IBeatReceiver;

enum abstract XMLAnimType(Int)
{
	var NONE = 0;
	var BEAT = 1;
	var LOOP = 2;

	public static function fromString(str:String, def:XMLAnimType = NONE)
	{
		return switch (str.trim().toLowerCase())
		{
			case "none": NONE;
			case "beat" | "onbeat": BEAT;
			case "loop": LOOP;
			default: def;
		}
	}
}

class FunkinSprite extends FlxSkewedSprite implements IBeatReceiver implements IOffsetCompatible implements IXMLEvents
{
	public var extra:Map<String, Dynamic> = [];

	public var spriteAnimType:XMLAnimType = NONE;
	public var beatAnims:Array<BeatAnim> = [];
	public var name:String;
	public var zoomFactor:Float = 1;
	public var initialZoom:Float = 1;
	public var debugMode:Bool = false;
	public var animDatas:Map<String, AnimData> = [];

	/**
	 * ODD interval -> asynced; EVEN interval -> synced
	 */
	public var beatInterval(default, set):Int = 2;
	public var beatOffset:Int = 0;
	public var skipNegativeBeats:Bool = false;

	public var animateAtlas:FlxAnimate;
	@:noCompletion public var atlasPlayingAnim:String;
	@:noCompletion public var atlasPath:String;

	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y);

		if (SimpleGraphic != null)
		{
			if (SimpleGraphic is String)
				loadSprite(cast SimpleGraphic);
			else
				loadGraphic(SimpleGraphic);
		}

		moves = false;
	}

	public static function copyFrom(source:FunkinSprite)
	{
		var spr = new FunkinSprite();
		@:privateAccess {
			spr.setPosition(source.x, source.y);
			spr.frames = source.frames;
			if (source.animateAtlas != null && source.atlasPath != null)
				spr.loadSprite(source.atlasPath);
			spr.animation.copyFrom(source.animation);
			spr.visible = source.visible;
			spr.alpha = source.alpha;
			spr.antialiasing = source.antialiasing;
			spr.scale.set(source.scale.x, source.scale.y);
			spr.scrollFactor.set(source.scrollFactor.x, source.scrollFactor.y);
			spr.skew.set(source.skew.x, source.skew.y);
			spr.transformMatrix = source.transformMatrix;
			spr.matrixExposed = source.matrixExposed;
			spr.animOffsets = source.animOffsets.copy();
		}
		return spr;
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (animateAtlas != null)
			animateAtlas.update(elapsed);

		// hate how it looks like but hey at least its optimized and fast  - Nex
		if (!debugMode && isAnimFinished()) {
			var name = getAnimName() + '-loop';
			if (hasAnimation(name))
				playAnim(name, null, lastAnimContext);
		}
	}

	public function loadSprite(path:String, Unique:Bool = false, Key:String = null)
	{
		var noExt = Path.withoutExtension(path);
		if (Assets.exists('$noExt/Animation.json'))
		{
			atlasPath = noExt;
			animateAtlas = new FlxAnimate(x, y, noExt);
		}
		else
		{
			frames = Paths.getFrames(path, true);
		}
	}

	public function onPropertySet(property:String, value:Dynamic) {
		if (property.startsWith("velocity") || property.startsWith("acceleration"))
			moves = true;
	}

	private var countedBeat = 0;
	public function beatHit(curBeat:Int)
	{
		if (beatAnims.length > 0 && (curBeat + beatOffset) % beatInterval == 0)
		{
			if(skipNegativeBeats && curBeat < 0) return;
			// TODO: find a solution without countedBeat
			var anim = beatAnims[FlxMath.wrap(countedBeat++, 0, beatAnims.length - 1)];
			if (anim.name != null && anim.name != "null" && anim.name != "none")
				playAnim(anim.name, anim.forced);
		}
	}

	public function stepHit(curBeat:Int)
	{
	}

	public function measureHit(curMeasure:Int)
	{
	}

	public override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect
	{
		__doPreZoomScaleProcedure(camera);
		var r = super.getScreenBounds(newRect, camera);
		__doPostZoomScaleProcedure();
		return r;
	}

	public override function drawComplex(camera:FlxCamera)
	{
		super.drawComplex(camera);
	}

	public override function doAdditionalMatrixStuff(matrix:FlxMatrix, camera:FlxCamera)
	{
		super.doAdditionalMatrixStuff(matrix, camera);
		matrix.translate(-camera.width / 2, -camera.height / 2);

		var requestedZoom = FlxMath.lerp(1, camera.zoom, zoomFactor);
		var diff = requestedZoom / camera.zoom;
		matrix.scale(diff, diff);
		matrix.translate(camera.width / 2, camera.height / 2);
	}

	public override function getScreenPosition(?point:FlxPoint, ?Camera:FlxCamera):FlxPoint
	{
		if (__shouldDoScaleProcedure())
		{
			__oldScrollFactor.set(scrollFactor.x, scrollFactor.y);
			var requestedZoom = FlxMath.lerp(initialZoom, camera.zoom, zoomFactor);
			var diff = requestedZoom / camera.zoom;

			scrollFactor.scale(1 / diff);

			var r = super.getScreenPosition(point, Camera);

			scrollFactor.set(__oldScrollFactor.x, __oldScrollFactor.y);

			return r;
		}
		return super.getScreenPosition(point, Camera);
	}

	// ANIMATE ATLAS DRAWING
	#if REGION
	public override function draw()
	{
		if (animateAtlas != null)
		{
			copyAtlasValues();
			animateAtlas.draw();
		}
		else
		{
			super.draw();
		}
	}

	public function copyAtlasValues()
	{
		@:privateAccess {
			animateAtlas.cameras = cameras;
			animateAtlas.scrollFactor = scrollFactor;
			animateAtlas.scale = scale;
			animateAtlas.offset = offset;
			animateAtlas.frameOffset = frameOffset;
			animateAtlas.x = x;
			animateAtlas.y = y;
			animateAtlas.angle = angle;
			animateAtlas.alpha = alpha;
			animateAtlas.visible = visible;
			animateAtlas.flipX = flipX;
			animateAtlas.flipY = flipY;
			animateAtlas.shader = shader;
			animateAtlas.shaderEnabled = shaderEnabled;
			animateAtlas.antialiasing = antialiasing;
			animateAtlas.skew = skew;
			animateAtlas.transformMatrix = transformMatrix;
			animateAtlas.matrixExposed = matrixExposed;
			animateAtlas.colorTransform = colorTransform;
		}
	}

	public override function destroy()
	{
		animateAtlas = FlxDestroyUtil.destroy(animateAtlas);

		if (animOffsets != null) {
			for (key in animOffsets.keys()) {
				final point = animOffsets[key];
				animOffsets.remove(key);
				if(point != null)
					point.put();
			}
			animOffsets = null;
		}
		super.destroy();
	}
	#end

	// SCALING FUNCS
	#if REGION
	private inline function __shouldDoScaleProcedure()
		return zoomFactor != 1;

	static var __oldScrollFactor:FlxPoint = new FlxPoint();
	static var __oldScale:FlxPoint = new FlxPoint();
	var __skipZoomProcedure:Bool = false;

	private function __doPreZoomScaleProcedure(camera:FlxCamera)
	{
		if (__skipZoomProcedure = !__shouldDoScaleProcedure())
			return;
		__oldScale.set(scale.x, scale.y);
		var requestedZoom = FlxMath.lerp(initialZoom, camera.zoom, zoomFactor);
		var diff = requestedZoom * camera.zoom;

		scale.scale(diff);
	}

	private function __doPostZoomScaleProcedure()
	{
		if (__skipZoomProcedure)
			return;
		scale.set(__oldScale.x, __oldScale.y);
	}
	#end

	// OFFSETTING
	#if REGION
	public var animOffsets:Map<String, FlxPoint> = new Map<String, FlxPoint>();

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = FlxPoint.get(x, y);
	}

	public function switchOffset(anim1:String, anim2:String)
	{
		var old = animOffsets[anim1];
		animOffsets[anim1] = animOffsets[anim2];
		animOffsets[anim2] = old;
	}
	#end

	// PLAYANIM
	#if REGION
	public var lastAnimContext:PlayAnimContext = DANCE;

	public function playAnim(AnimName:String, ?Force:Null<Bool>, Context:PlayAnimContext = NONE, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (AnimName == null)
			return;

		if (Force == null) {
			var anim = animDatas.get(AnimName);
			Force = anim != null && anim.forced;
		}

		if (animateAtlas != null)
		{
			@:privateAccess
			// if (!animateAtlas.anim.animsMap.exists(AnimName) && !animateAtlas.anim.symbolDictionary.exists(AnimName)) return;
			animateAtlas.anim.play(AnimName, Force, Reversed, Frame);
			atlasPlayingAnim = AnimName;
		}
		else
		{
			if (!animation.exists(AnimName) && !debugMode)
				return;
			animation.play(AnimName, Force, Reversed, Frame);
		}

		var daOffset = getAnimOffset(AnimName);
		frameOffset.set(daOffset.x, daOffset.y);
		daOffset.putWeak();

		lastAnimContext = Context;
	}

	public function getAnim(name:String):OneOfTwo<FlxAnimation, FlxSymbolAnimation> {
		if(animateAtlas != null)
			return animateAtlas.anim.getByName(name);
		return animation.getByName(name);
	}

	public inline function getAnimOffset(name:String)
	{
		if (animOffsets.exists(name))
			return animOffsets[name];
		return FlxPoint.weak(0, 0);
	}

	public inline function hasAnimation(AnimName:String):Bool @:privateAccess
		return animateAtlas != null ? (animateAtlas.anim.animsMap.exists(AnimName)
			|| animateAtlas.anim.symbolDictionary.exists(AnimName)) : animation.exists(AnimName);

	public inline function getAnimName()
	{
		var name = null;
		if (animateAtlas != null)
		{
			name = atlasPlayingAnim;
		}
		else
		{
			if (animation.curAnim != null)
				name = animation.curAnim.name;
		}
		return name;
	}

	public inline function isAnimReversed():Bool {
		return animateAtlas != null ? animateAtlas.anim.reversed : animation.curAnim != null ? animation.curAnim.reversed : false;
	}

	public inline function removeAnimation(name:String) {
		if (animateAtlas != null)
			@:privateAccess animateAtlas.anim.animsMap.remove(name);
		else
			animation.remove(name);
	}

	public inline function getNameList():Array<String> {
		if (animateAtlas != null)
			return [for (name in @:privateAccess animateAtlas.anim.animsMap.keys()) name];
		else
			return animation.getNameList();
	}

	public inline function stopAnimation() {
		if (animateAtlas != null)
			animateAtlas.anim.pause();
		else
			animation.stop();
	}

	public inline function isAnimFinished()
	{
		return animateAtlas != null ? animateAtlas.anim.finished : (animation.curAnim != null ? animation.curAnim.finished : true);
	}

	public inline function isAnimAtEnd() {
		return animateAtlas != null ? animateAtlas.anim.isAtEnd : (animation.curAnim != null ? animation.curAnim.isAtEnd : false);
	}
	#end

	// Getter / Setters

	@:noCompletion private function set_beatInterval(v:Int) {
		if (v < 1)
			v = 1;

		return beatInterval = v;
	}
}
