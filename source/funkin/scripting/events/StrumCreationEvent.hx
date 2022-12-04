package funkin.scripting.events;

import funkin.game.Strum;

class StrumCreationEvent extends CancellableEvent {
    @:dox(hide) public var __doAnimation = !PlayState.isStoryMode;


    /**
     * The strum that is being created
     */
    public var strum:Strum;

    /**
     * Player ID
     */
    public var player:Int;

    /**
     * Strum ID, for the sprite.
     */
    public var strumID:Int;

    /**
     * Sprite path, in case you only want to change the sprite.
     */
    public var sprite:String = "game/NOTE_assets";

    public function new(strum:Strum, player:Int, strumID:Int) {
        super();
        this.strum = strum;
        this.player = player;
        this.strumID = strumID;
    }

    /**
     * Cancels the animation that makes the strum "land" in the strumline.
     */
    public function cancelAnimation() {__doAnimation = false;}
    @:dox(hide) public function preventAnimation() {cancelAnimation();}
}