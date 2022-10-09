package funkin.scripting.events;

import funkin.game.Note;
import funkin.game.Character;

class NoteHitEvent extends CancellableEvent {
    public var note:Note;
    public var character:Character;
    public var player:Bool;
    public var noteType:String;

    public function new(note:Note, char:Character, player:Bool, ?noteType:String) {
        super(true);

        this.note = note;
        this.character = char;
        this.player = player;
        this.noteType = noteType;
    }
}