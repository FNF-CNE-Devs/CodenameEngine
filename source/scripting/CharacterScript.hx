package scripting;

import funkin.scripting.events.*;

/**
 * Contains all callbacks you can add in a Character script.
 *
 * To add a Character script, create a file here: `data/characters/my-char.hx`
 */
interface CharacterScript {
    /**
     * Triggered after the characters XML has been loaded.
     */
    public function create():Void;

    /**
     * Triggered after the character has been entirely loaded.
     */
    public function postCreate():Void;

    /**
     * Triggered every frame.
     */
    public function update(elapsed:Float):Void;

    /**
     * Triggered everytime the character will dance (play its idle animation).
     */
    public function onDance(event:DanceEvent):Void;

    /**
     * Triggered every beat
     */
    public function beatHit(curBeat:Int):Void;

    /**
     * Triggered every step
     */
    public function stepHit(curStep:Int):Void;

    /**
     * Triggered everytime the game tries to play an animation on your character.
     */
    public function onPlayAnim(event:PlayAnimEvent):Void;

    /**
     * Triggered everytime the game tries to get your player's camera position.
     * This event cannot be cancelled.
     */
    public function onGetCamPos(event:PointEvent):Void;

    /**
     * Triggered everytime the game tries to play a sing, alt sing or miss animation.
     */
    public function onPlaySingAnim(event:DirectionAnimEvent):Void;

    
}