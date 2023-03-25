package funkin.system.framerate;

class FlixelInfo extends FramerateCategory {
	public function new() {
		super("Flixel Info");
	}

	public override function __enterFrame(t:Int) {
		if (alpha <= 0.05) return;
		_text = 'State: ${Type.getClassName(Type.getClass(FlxG.state))}';
		_text += '\nObject Count: ${FlxG.state.members.length}';
		_text += '\nCamera Count: ${FlxG.cameras.list.length}';
		@:privateAccess
		_text += '\nFlxG.game Childs Count: ${FlxG.game.numChildren}';
		
		this.text.text = _text;
		super.__enterFrame(t);
	}
}