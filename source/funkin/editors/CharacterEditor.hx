package funkin.editors;

import funkin.desktop.DesktopMain;
import flixel.FlxG;
import flixel.FlxState;
import funkin.game.*;

class CharacterEditor extends MusicBeatState {
    public var character:Character;
    public var characterName:String;

    private var oldState:Class<FlxState> = null;
    public function new(char:String) {
        super();
        this.characterName = char;
        if (!(FlxG.state is DesktopMain))
            oldState = Type.getClass(FlxG.state);
    } 

    public override function create() {
        super.create();

        add(new Stage("default"));
        
        character = new Character(770, 100, characterName, true);
        characterName = character.curCharacter;
        add(character);

        trace(members);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (controls.BACK && oldState != null)
            FlxG.switchState(Type.createInstance(oldState, []));
    }
}