package scripting;

import funkin.backend.scripting.events.*;

/**
 * Contains all callbacks you can add in modcharts and stage scripts.
 * 
 * 
 * 
 * NOTE: In case you're scripting a stage, all sprites of that stage are directly accessible via their name.
 * 
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
	public function postCreate():Void;

	/**
	 * Triggered every frame.
	 * @param elapsed Time elapsed since last frame.
	 */
	public function update(elapsed:Float):Void;

	/**
	 * Triggered at the end of every frame.
	 * @param elapsed Time elapsed since last frame.
	 */
	public function postUpdate(elapsed:Float):Void;

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
	 * Triggered every countdown.
	 * @param event Countdown event.
	 */
	public function onCountdown(event:CountdownEvent):Void;

	/**
	 * Triggered after every countdown.
	 * @param event Countdown event.
	 */
	public function onPostCountdown(event:CountdownEvent):Void;

	/**
	 * Triggered whenever the player hits a note.
	 * @param note Event object with the note being pressed, the character who pressed it, and functions to alter or cancel the default behaviour.
	 */
	public function onPlayerHit(event:NoteHitEvent):Void;

	/**
	 * Triggered whenever the opponent hits a note.
	 * @param note Event object with the note being pressed, the character who pressed it, and functions to alter or cancel the default behaviour.
	 */
	public function onDadHit(event:NoteHitEvent):Void;

	/**
	 * Triggered whenever the input system updates.
	 * @param note Event object with the pressed notes, which allows you to alter which notes are being pressed during this frame, or simply cancel the input update.
	 */
	public function inputUpdate(event:InputSystemEvent):Void;

	/**
	 * Triggered after the input system updates.
	 * @param note Event object with the pressed, justPressed and justReleased notes.
	 */
	public function inputPostUpdate(event:InputSystemEvent):Void;

	/**
	 * Triggered on each note creation
	 * @param event Event object containing information about the note.
	 */
	public function onNoteCreation(event:NoteCreationEvent):Void;

	/**
	 * Triggered on each strum creation
	 * @param event Event object containing information about the strum.
	 */
	public function onStrumCreation(event:StrumCreationEvent):Void;

	/**
	 * Triggered on substate open.
	 * @param event Event object containing the substate, which is cancellable.
	 */
	public function onSubstateOpen(event:StateEvent):Void;

	/**
	 * Triggered on substate close.
	 * @param event Event object containing the substate, which is cancellable.
	 */
	public function onSubstateClose(event:StateEvent):Void;
}