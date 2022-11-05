package funkin.scripting.events;

import funkin.game.Note;

class NoteCreationEvent extends CancellableEvent {
    /**
     * Note that is being created
     */
    public var note:Note;

    /**
     * ID of the strum (from 0 to 3)
     */
    public var strumID:Int;

    /**
     * Note Type (ex: "My Super Cool Note", or "Mine")
     */
    public var noteType:String;

    /**
     * ID of the note type.
     */
    public var noteTypeID:Int;

    /**
     * Whenever the note will need to be hit by the player
     */
    public var mustHit:Bool;

    /**
     * Note sprite, if you only want to replace the sprite.
     */
    public var noteSprite:String;

    /**
     * Note scale, if you only want to replace the scale.
     */
    public var noteScale:Float;

    /**
     * Sing animation suffix. "-alt" for alt anim or "" for normal notes.
     */
    public var animSuffix:String;

    /**
     * [Description] Creates a new NoteCreationEvent
     * @param note 
     * @param strumID 
     * @param noteType 
     * @param noteTypeID 
     * @param mustHit 
     */
    public function new(note:Note, strumID:Int, noteType:String, noteTypeID:Int, mustHit:Bool, noteSprite:String, noteScale:Float, animSuffix:String) {
        super();
        this.note = note;
        this.strumID = strumID;
        this.noteType = noteType;
        this.noteTypeID = noteTypeID;
        this.mustHit = mustHit;
        this.noteSprite = noteSprite;
        this.noteScale = noteScale;
        this.animSuffix = animSuffix;
    }
}