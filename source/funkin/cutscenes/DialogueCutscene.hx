package funkin.cutscenes;

class DialogueCutscene extends Cutscene {
    public var dialoguePath:String;

    public function new(dialoguePath:String, callback:Void->Void) {
        super(callback);
        this.dialoguePath = dialoguePath;
    }
}