package funkin.scripting.events;

import funkin.game.Note;
import funkin.game.Character;

class NoteHitEvent extends CancellableEvent {
    @:dox(hide) public var animCancelled:Bool = false;

    public var note:Note;
    public var character:Character;
    public var player:Bool;
    public var noteType:String;
    public var direction:Int;

    /**
     * Creates a new NoteHitEvent with the following values:
     * @param note 
     * @param character 
     * @param player 
     * @param noteType 
     */
    public function new(note:Note, character:Character, player:Bool, noteType:String, direction:Int) {
        super();

        this.note = note;
        this.character = character;
        this.player = player;
        this.noteType = noteType;
        this.direction = direction;
    }

    /**
     * Prevents the default sing animation from being played.
     */
    public function preventAnim() {
        animCancelled = true;
    }

    @:dox(hide)
    public function cancelAnim() {preventAnim();}
}