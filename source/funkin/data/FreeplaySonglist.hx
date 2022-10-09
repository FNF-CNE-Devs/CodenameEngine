package funkin.data;

import flixel.util.FlxColor;
import openfl.utils.Assets;
import funkin.menus.FreeplayState;
import haxe.Json;

class FreeplaySonglist {
    public var addOGSongs:Bool = false;
    public var songs:Array<SongMetadata> = [];

    public function new() {

    }

    private function _addJSONSongs(songs:Array<FreeplaySong>) {
        if (songs != null && songs is Array) {
            for(e in songs) {
                if (e is Dynamic) {
                    if (e.name == null) continue;
                    if (e.icon == null) e.icon = "bf";
                    if (e.color == null) e.color = FreeplayState.defaultColor;
                    this.songs.push(new SongMetadata(e.name,
                        CoolUtil.getDefault(e.icon, "bf"),
                        CoolUtil.getDefault(CoolUtil.getColorFromDynamic(e.color), FreeplayState.defaultColor)));
                }
            }
        }
    }

    public static function get() {
        var songList = new FreeplaySonglist();

        var jsonPath = Paths.json("freeplaySonglist");
        var baseJsonPath = Paths.getPath('data/freeplaySonglist.json', TEXT, null, true);

        try {
            var json:FreeplayJSON = Json.parse(Assets.getText(jsonPath));
            var addOGSongs = CoolUtil.getDefault(json.addOGSongs, true);
            songList._addJSONSongs(json.songs);
            if (addOGSongs && (jsonPath != baseJsonPath)) {
                var json:FreeplayJSON = Json.parse(Assets.getText(baseJsonPath));
                songList._addJSONSongs(json.songs);
            }
        }

        return songList;
    }
}

typedef FreeplayJSON = {
    public var addOGSongs:Null<Bool>;
    public var songs:Array<FreeplaySong>;
}

typedef FreeplaySong = {
    public var name:String;
    public var icon:String;
    public var color:Dynamic;
}

class SongMetadata
{
	public var songName:String = "";
	public var color:FlxColor = FreeplayState.defaultColor;
	public var songCharacter:String = "";

	public function new(song:String, songCharacter:String, color:FlxColor)
	{
		this.songName = song;
		this.color = color;
		this.songCharacter = songCharacter;
	}
}
