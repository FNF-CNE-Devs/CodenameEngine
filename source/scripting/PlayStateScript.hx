package scripting;

import funkin.scripting.events.*;

/**
 * Contains all callbacks you can add in modcharts and stage scripts.
 * 
 * NOTE: In case you're scripting a stage, all sprites of that stage are directly accessible via their name.
 * Ex: If you added a `superCoolBG` element in your stage XML, you'll be able to access it via scripts by using `superCoolBG`.
 */
interface PlayStateScript {
    /**
     * Triggered after the characters has been created, during PlayState's creation.
     */
    public function create():Void;

    /**
     * Triggered at the very end of PlayState's creation
     */
    public function createPost():Void;

    /**
     * Triggered every frame.
     * @param elapsed Time elapsed since last frame.
     */
    public function update(elapsed:Float):Void;

    /**
     * Triggered at the end of every frame.
     * @param elapsed Time elapsed since last frame.
     */
    public function updatePost(elapsed:Float):Void;

    /**
     * Triggered every step
     * @param curStep Current step.
     */
    public function stepHit(curStep:Int):Void;

    /**
     * Triggered every beat.
     * @param curBeat Current beat.
     */
    public function beatHit(curBeat:Int):Void;

    /**
     * Triggered whenever the player hits a note.
     * @param note Event object with the note being pressed, the character who pressed it, and functions to alter or cancel the default behaviour.
     */
    public function onPlayerHit(note:NoteHitEvent):Void;

    /**
     * Triggered whenever the opponent hits a note.
     * @param note Event object with the note being pressed, the character who pressed it, and functions to alter or cancel the default behaviour.
     */
    public function onDadHit(note:NoteHitEvent):Void;

    /**
     * Triggered whenever the input system updates.
     * @param note Event object with the pressed notes, which allows you to alter which notes are being pressed during this frame, or simply cancel the input update.
     */
    public function inputUpdate(note:InputSystemEvent):Void;

    /**
     * Triggered after the input system updates.
     * @param note Event object with the pressed, justPressed and justReleased notes.
     */
    public function inputUpdatePost(note:InputSystemEvent):Void;
}