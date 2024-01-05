package funkin.editors.charter;

import flixel.math.FlxPoint;
import haxe.io.Path;

class EditNoteTypesList extends UISubstateWindow {
	public static var pathString:String = 'data/notes/';

	public var noteTypesList:UIButtonList<NoteTypeButton>;
	public var saveButton:UIButton;
	public var closeButton:UIButton;

	public override function create() {
		FlxG.sound.music.pause();
		Charter.instance.vocals.pause();

		winTitle = 'Note Types List Editor';
		winWidth = 380; winHeight = 390;

		super.create();

		var title:UIText;
		add(title = new UIText(windowSpr.x + 25, windowSpr.y + 15 + 16, 0, "Edit Note Types List", 28));

		var noteTypesFileList = getNoteTypesList(true);
		if (noteTypesFileList.length == 0) noteTypesFileList = getNoteTypesList(false);
		var list:Array<String> = Charter.instance.noteTypes;

		noteTypesList = new UIButtonList<NoteTypeButton>(15, title.y + title.height + 10, winWidth - 35, 260, "", FlxPoint.get(winWidth - 35, 60), null, 0);
		noteTypesList.addButton.callback = () -> noteTypesList.add(new NoteTypeButton(0, 0, "New Note Type", noteTypesFileList, noteTypesList));
		noteTypesList.cameraSpacing = 0;
		for (i in list)
			noteTypesList.add(new NoteTypeButton(0, 0, i, noteTypesFileList, noteTypesList));
		add(noteTypesList);
		noteTypesList.frames = Paths.getFrames('editors/ui/inputbox');

		saveButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20 - 125, windowSpr.y + windowSpr.bHeight - 16 - 32, "Save & Close", function() {
			saveList();
			close();
		}, 125);
		add(saveButton);

		closeButton = new UIButton(saveButton.x - 20, saveButton.y, "Close", function() {
			close();
		}, 125);
		add(closeButton);
		closeButton.color = 0xFFFF0000;
		closeButton.x -= closeButton.bWidth;
	}

	public function getNoteTypesList(?mods:Bool = false) {
		var list:Array<String> = [];
		for (path in Paths.getFolderContent(pathString, true, mods ? MODS : BOTH)) if(Path.extension(path) == "hx") {
				var file:String = Path.withoutDirectory(path);
				if (!list.contains(file)) list.push(file);
			}

		return list;
	}

	public function saveList()
	{
		var oldList:Array<String> = Charter.instance.noteTypes;
		var newList:Array<String> = [for (note in noteTypesList.buttons.members) note.textBox.label.text];
		Charter.instance.noteTypes = newList;
		Charter.instance.changeNoteType(null, false);
		Charter.instance.undos.addToUndo(CEditNoteTypes(oldList, newList));
	}
}

class NoteTypeButton extends UIButton {
	public var textBox:UIAutoCompleteTextBox;
	public var deleteButton:UIButton;
	public var deleteIcon:FlxSprite;
	public var list:Array<String>;

	public function new(x:Float, y:Float, name:String, list:Array<String>, parent:UIButtonList<NoteTypeButton>) {
		super(x, y, '', null, Std.int(parent.buttonSize.x), Std.int(parent.buttonSize.y));
		autoAlpha = false;

		members.push(textBox = new UIAutoCompleteTextBox(5, bHeight/2 - 40, name, 250));
		textBox.suggestItems = [for(script in (this.list = list)) Path.withoutExtension(script)];
		textBox.antialiasing = true;

		field.alignment = LEFT;
		field.x = textBox.x;
		field.y = textBox.y + textBox.height + 30;
		field.height = 9;

		deleteButton = new UIButton(textBox.x + textBox.label.width + 10, textBox.y - 8, "", function () {
			parent.remove(this);
		}, 32);
		deleteButton.color = 0xFFFF0000;
		deleteButton.autoAlpha = false;
		members.push(deleteButton);

		deleteIcon = new FlxSprite(deleteButton.x + (15/2), deleteButton.y + 8).loadGraphic(Paths.image('editors/delete-button'));
		deleteIcon.antialiasing = false;
		members.push(deleteIcon);
	}

	private var lastName:String = null;
	override function update(elapsed) {
		deleteButton.y = y + bHeight / 2 - deleteButton.bHeight / 2 - 8;
		textBox.y = y + bHeight/2 - 20;
		deleteIcon.x = deleteButton.x + (15/2); deleteIcon.y = deleteButton.y + 8;

		deleteButton.selectable = selectable;
		deleteButton.shouldPress = shouldPress;

		super.update(elapsed);
		field.follow(this, textBox.x, textBox.x + textBox.height + 30);
		if(lastName != textBox.label.text) {
			lastName = textBox.label.text;

			var toUse:String = 'Path: ${EditNoteTypesList.pathString}$lastName.';
			for(name in list) if(Path.withoutExtension(name) == lastName) {
				toUse += Path.extension(name);
				break;
			}
			if(Path.extension(toUse) == "") toUse += '?';
			field.text = toUse;
		}
	}
}