package funkin.backend.system.framerate;

class FlixelInfo extends FramerateCategory {
	public function new() {
		super("Flixel Info");
	}

	public override function __enterFrame(t:Int) {
		if (alpha <= 0.05) return;


		@:privateAccess {
			var c:Int = 0;
			for(_ in FlxG.bitmap._cache.keys())
				c++;
			
			_text = 'State: ${Type.getClassName(Type.getClass(FlxG.state))}';
			_text += '\nObject Count: ${FlxG.state.members.length}';
			_text += '\nCamera Count: ${FlxG.cameras.list.length}';
			_text += '\nBitmaps Count: ${c}';
			_text += '\nSounds Count: ${FlxG.sound.list.length}';
			_text += '\nFlxG.game Childs Count: ${FlxG.game.numChildren}';
			// _text += '\nCached objects count: ${cachedObjects}';
			#if FLX_POINT_POOL
			var points = flixel.math.FlxPoint.FlxBasePoint.pool;
			//_text += '\nPoint Count: ${points._count} | +${points.made} | -${points.gotten} | ${points.balance} | >${points.putted}';
			_text += '\nPoint Count: ${points._count}';
			#end
		}
		
		this.text.text = _text;
		super.__enterFrame(t);
	}
}