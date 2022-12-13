package scripting;

import flixel.FlxState;
/**
 * A global script is a special kind of script that runs on everywhere on your mod: menus, game, etc...
 * 
 * To create one, go to data and create a script named "global", then press F5 in game to hot reload.
 * 
 * All flixel signals are automatically binded, as shown below.
 */
interface GlobalScript {
    /**
     * Called whenever the game gains focus.
     */
    public function focusGained():Void;
    /**
     * Called whenever the game loses focus.
     */
    public function focusLost():Void;
    /**
     * Called whenever the game loses focus.
     * @param width Width of the game
     * @param height Height of the game
     */
    public function gameResized(width:Int, height:Int):Void;

    /**
     * Called after the screen has been drawn.
     */
    public function postDraw():Void;
    
    /**
     * Called after the game has been reset.
     */
    public function postGameReset():Void;
    
    /**
     * Called after the game has been started.
     */
    public function postGameStart():Void;
    
    /**
     * Called after the state has been switched.
     */
    public function postStateSwitch():Void;
    
    /**
     * Called after the game has been updated.
     * 
     * Aliases: `postUpdate`
     * 
     * @param elapsed Time elapsed since last frame
     */
    public function postUpdate(elapsed:Float):Void;
    
    /**
     * Called before the game draws on screen.
     */
    public function preDraw():Void;

    /**
     * Called before the game resets.
     */
    public function preGameReset():Void;

    /**
     * Called before the game starts.
     */
    public function preGameStart():Void;

    /**
     * Called before the state creates.
     */
    public function preStateCreate(state:FlxState):Void;

    /**
     * Called before the state switches.
     */
    public function preStateSwitch():Void;

    /**
     * Called before the game updates.
     * 
     * Aliases: `preUpdate`
     */
    public function update(elapsed:Float):Void;
}
