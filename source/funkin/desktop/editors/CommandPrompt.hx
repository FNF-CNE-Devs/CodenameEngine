package funkin.desktop.editors;

class CommandPrompt extends WindowContent {
    public function new() {
        super("Command Prompt", 100, 100, 960, 480);
    }

    public override function create() {
        super.create();
        windowCamera.bgColor = 0xFF000000;
    }
}