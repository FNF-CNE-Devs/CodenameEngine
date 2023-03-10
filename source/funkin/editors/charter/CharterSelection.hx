package funkin.editors.charter;

import funkin.menus.FreeplayState.FreeplaySonglist;

class CharterSelection extends MusicBeatState {
    public var songNames:FlxTypedSpriteGroup<Alphabet>;
    public var freeplaySonglist:FreeplaySonglist;

    public override function create() {
        super.create();

        songNames = new FlxTypedSpriteGroup<Alphabet>();

        freeplaySonglist = FreeplaySonglist.get();

        for(k=>s in freeplaySonglist.songs) {
            var alphabet = new Alphabet(0, k * 60, s.displayName, true);
            songNames.add(alphabet);
        }

        add(songNames);
    }
}