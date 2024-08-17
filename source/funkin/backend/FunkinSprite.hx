package funkin.backend;

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
	 * Linked Sprite Stuff
	 * defaultSelfAlpha & defaultLinkAlpha is so it can alternate between sprites if wanted
	 		  * doLinkSwitching enables that ^^
	 * doLinkVisiblitySync makes it so that if the parent sprite.visible is set to false, so will the child sprite.
	 * doLinkPositionSync makes it so that the child sprite positions equals that of the parent sprite.
	 */
	 public var linkedSprites:Array<FunkinSprite> = []; // You can now link more than one to a parent :D
    
	 public var linkingTag:String;
	 
	 public var doLinkSwitching:Bool = true;
	 public var doLinkPositionSync:Bool = true; // Should be off by default? Idrk.
	 public var doLinkVisiblitySync:Bool = true;
 
	 private var defaultSelfAlpha:Float;
	 private var defaultLinkAlpha:Float;
 
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
		updateLiniage();
	}

	function updateLiniage() {
		for (linkedSprite in linkedSprites) {
			linkedSprite.visible = linkedSprite != null ? (doLinkVisiblitySync ? visible : linkedSprite.visible) : return;

			if (alpha != defaultSelfAlpha && alpha != 0.000574705) { // Random number, so it will actually overwrite shiz.
				defaultSelfAlpha = alpha;
			} else if (linkedSprite.alpha != defaultLinkAlpha
				&& linkSprite.alpha != 0.000574705) { // Random number, so it will actually overwrite shiz.
				defaultLinkAlpha = linkedSprite.alpha;
			} else if (doLinkPositionSync) {
				linkedSprite.x = x;
				linkedSprite.y = y;
			}
		}
	}

	function getLinkedSpriteByTag(tag:String) {
        for (linkedSprite in linkedSprite) {
            if (linkedSprite.linkingTag == tag) {
                return linkedSprite;
            }
        }
    }

	function addLinkedSprite(daSprite:FunkinSprite, ?overwriteLinkData = false, ?tag:String) {
		doLinkPositionSync = overwriteLinkData;
		if (overwriteLinkData) {
			daSprite.alpha = alpha;
			daSprite.x = x;
			daSprite.y = y;
		}
        daSprite.linkingTag = tag;
		defaultLinkAlpha = daSprite.alpha;
		defaultSelfAlpha = alpha;

		daSprite.alpha = 0.000574705;
		linkedSprites.push(daSprite);
	}

	function setDoLinkSwitching(doSwitch:Bool) {
		doLinkSwitching = if (doSwitch != null) { doLinkSwitching = doSwitch; };
		if (!doLinkSwitching) {
			for (linkedSprite in linkedSprites) {
				linkedSprite.alpha = defaultLinkAlpha;
			}
			alpha = defaultSelfAlpha;
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
			animateAtlas.antialiasing = antialiasing;
			animateAtlas.skew = skew;
			animateAtlas.transformMatrix = transformMatrix;
			animateAtlas.matrixExposed = matrixExposed;
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

	public function playAnim(AnimName:String, Force:Bool = false, Context:PlayAnimContext = NONE, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (AnimName == null)
            return;

        var spriteIsOffAlpha:Float = 0.000574705; // DO NOT change, this number needs to be this random float, or else you can't change the parent sprite alpha, trust me. - Nebula S. Nova
        if (animateAtlas != null)
        {
            @:privateAccess
            if (!animateAtlas.anim.animsMap.exists(AnimName) && !animateAtlas.anim.symbolDictionary.exists(AnimName)) {
                for (linkedSprite in linkedSprites) {
                    if (linkedSprite.animateAtlas != null) {
                        if (!linkedSprite.animateAtlas.anim.animsMap.exists(AnimName) && !linkedSprite.animateAtlas.anim.symbolDictionary.exists(AnimName)) {} else {
                            linkedSprite.playAnim(AnimName, Force, Context, Reversed, Frame);
                            linkedSprite.alpha = doLinkSwitching ? defaultLinkAlpha : linkedSprite.alpha;
						    alpha = doLinkSwitching ? spriteIsOffAlpha : alpha;
                            return;
                        }
                    }
                }
            } else {
				linkedSprite.alpha = doLinkSwitching ? spriteIsOffAlpha : linkedSprite.alpha;
				alpha = doLinkSwitching ? defaultSelfAlpha : alpha;
                animateAtlas.anim.play(AnimName, Force, Reversed, Frame);
                atlasPlayingAnim = AnimName;
            }
        } else {
            if (!animation.exists(AnimName) && !debugMode) {
                for (linkedSprite in linkedSprites) { 
                    if (!linkedSprite.animation.exists && !debugMode) {} else {
                        linkedSprite.playAnim(AnimName, Force, Context, Reversed, Frame);
                        linkedSprite.alpha = doLinkSwitching ? defaultLinkAlpha : linkedSprite.alpha;
                        alpha = doLinkSwitching ? spriteIsOffAlpha : alpha;
                        return;
                    }
                }
            } else {
				linkedSprite.alpha = doLinkSwitching ? spriteIsOffAlpha : linkedSprite.alpha;
				alpha = doLinkSwitching ? defaultSelfAlpha : alpha;
                animation.play(AnimName, Force, Reversed, Frame);
            }

        }
        var daOffset = getAnimOffset(AnimName);
        frameOffset.set(daOffset.x, daOffset.y);
        daOffset.putWeak();

        lastAnimContext = Context;
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
		return animateAtlas != null ? (animateAtlas.anim.finished) : (animation.curAnim != null ? animation.curAnim.finished : true);
	}
	#end

	// Getter / Setters

	@:noCompletion private function set_beatInterval(v:Int) {
		if (v < 1)
			v = 1;

		return beatInterval = v;
	}
}
