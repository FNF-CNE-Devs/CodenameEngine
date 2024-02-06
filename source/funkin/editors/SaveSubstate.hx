package funkin.editors;

#if desktop
import sys.io.File;
#end
import haxe.io.Path;
import lime.ui.FileDialog;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;

class SaveSubstate extends MusicBeatSubstate {
	public var saveOptions:Map<String, Bool>;
	public var options:SaveSubstateData;

	public var data:String;

	public var cam:FlxCamera;

	public function new(data:String, ?options:SaveSubstateData, ?saveOptions:Map<String, Bool>) {
		super();
		this.data = data;

		if (saveOptions == null)
			saveOptions = [];
		this.saveOptions = saveOptions;

		if (options != null)
			this.options = options;
	}

	public override function create() {
		super.create();

		var fileDialog = new FileDialog();
		fileDialog.onCancel.add(function() {
			close();
		});
		fileDialog.onSelect.add(function(str) {
			#if desktop
			File.saveContent(str, data);
			#end
			close();
		});
		fileDialog.browse(SAVE, options.saveExt.getDefault(Path.extension(options.defaultSaveFile)), options.defaultSaveFile);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		parent.persistentUpdate = false;
	}

	private function onError(_) {
		// TODO: error handling
		close();
	}
}

typedef SaveSubstateData = {
	var ?defaultSaveFile:String;
	var ?saveExt:String;
}