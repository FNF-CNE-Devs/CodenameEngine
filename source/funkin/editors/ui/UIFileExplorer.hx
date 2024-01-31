package funkin.editors.ui;

import haxe.io.Bytes;
import lime.ui.FileDialog;

class UIFileExplorer extends UISliceSprite {
	public var uploadButton:UIButton;
	public var uploadIcon:FlxSprite;

	public var deleteButton:UIButton;
	public var deleteIcon:FlxSprite;

	public var file:Bytes = null;
	public var onFile:Bytes->Void;

	public var uiElement:UISprite;

	public function new(x:Float, y:Float, ?w:Int, ?h:Int, fileType:String = "txt", ?onFile:Bytes->Void) {
		super(x, y, (w != null ? w : 320), (h != null ? h : 58), 'editors/ui/inputbox');

		if (onFile != null) this.onFile = onFile;

		uploadButton = new UIButton(x + 8, y+ 8, "", function () {
			var fileDialog = new FileDialog();
			fileDialog.onOpen.add(function(res) {
				file = cast res;
				deleteButton.visible = deleteButton.selectable = deleteIcon.visible = !(uploadButton.visible = uploadButton.selectable = false);

				if (this.onFile != null) this.onFile(file);
			});
			fileDialog.open(fileType);
		}, bWidth - 16, bHeight - 16);
		members.push(uploadButton);

		uploadIcon = new FlxSprite(uploadButton.x + (uploadButton.bWidth / 2) - 8, uploadButton.y + ((bHeight-16)/2) - 8).loadGraphic(Paths.image('editors/ui/upload-button'));
		uploadIcon.antialiasing = false;
		uploadButton.members.push(uploadIcon);

		deleteButton = new UIButton(x + bWidth - (bHeight - 16) - 8, y + 8, "", removeFile, bHeight - 16, bHeight - 16);
		deleteButton.color = 0xFFFF0000;
		members.push(deleteButton);

		deleteIcon = new FlxSprite(deleteButton.x + ((bHeight - 16)/2) - 8, deleteButton.y + ((bHeight - 16)/2) - 8).loadGraphic(Paths.image('editors/delete-button'));
		deleteIcon.antialiasing = false;
		members.push(deleteIcon);

		deleteButton.visible = deleteButton.selectable = deleteIcon.visible = false;
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		alpha = selectable ? 1 : 0.4;
		uploadButton.alpha = deleteButton.alpha = deleteIcon.alpha = uploadIcon.alpha = alpha;

		if (uiElement != null) {
			uiElement.alpha = alpha;
			if (uiElement is UIButton)
				cast(uiElement, UIButton).selectable = selectable;
		}
	}

	public function removeFile() {
		if (uiElement != null) {
			members.remove(uiElement);
			uiElement.destroy();
		}

		file = null;
		MemoryUtil.clearMajor();

		deleteButton.visible = deleteButton.selectable = deleteIcon.visible = !(uploadButton.visible = uploadButton.selectable = true);
	}
}