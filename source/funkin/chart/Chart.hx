package funkin.chart;

import flixel.util.FlxColor;
import haxe.io.Path;
import funkin.system.Song.SwagSong;
import haxe.Json;
import openfl.utils.Assets;

class Chart {
    public static function loadChartMeta(songName:String, difficulty:String = "normal") {
        var metaPath = Paths.file('songs/${songName.toLowerCase()}/meta.json');
        var metaDiffPath = Paths.file('songs/${songName.toLowerCase()}/meta-${difficulty.toLowerCase()}.json');

        var data:ChartMetaData = null;
        var fromMods:Bool = false;
        for(path in [metaDiffPath, metaPath]) {
            if (Assets.exists(path)) {
                fromMods = Paths.assetsTree.existsSpecific(path, "TEXT", MODS);
                try {
                    data = Json.parse(Assets.getText(path));
                } catch(e) {
                    Logs.trace('Failed to load song metadata for ${songName} ($path): ${Std.string(e)}', ERROR);
                }
                if (data != null) break;
            }
        }

        if (data == null)
            data = {
                name: songName,
                bpm: 100
            };
        data.setFieldDefault("name", songName);
        data.setFieldDefault("beatsPerMesure", 4);
        data.setFieldDefault("stepsPerBeat", 4);
        data.setFieldDefault("needsVoices", true);
        data.setFieldDefault("icon", "face");
        data.setFieldDefault("difficulties", []);
        data.setFieldDefault("coopAllowed", false);
        data.setFieldDefault("opponentModeAllowed", false);
        data.setFieldDefault("displayName", data.name);
        data.setFieldDefault("parsedColor", data.color.getColorFromDynamic());

        if (data.difficulties.length <= 0) {
            data.difficulties = [for(f in Paths.getFolderContent('songs/${songName.toLowerCase()}/charts/', false, !fromMods)) if (Path.extension(f = f.toUpperCase()) == "JSON") Path.withoutExtension(f)];
			if (data.difficulties.length == 3) {
				var hasHard = false, hasNormal = false, hasEasy = false;
				for(d in data.difficulties) {
					switch(d) {
						case "EASY":	hasEasy = true;
						case "NORMAL":	hasNormal = true;
						case "HARD":	hasHard = true;
					}
				}
				if (hasHard && hasNormal && hasEasy) {
					data.difficulties[0] = "EASY";
					data.difficulties[1] = "NORMAL";
					data.difficulties[2] = "HARD";
				}
			}
        }
        if (data.difficulties.length <= 0)
            data.difficulties.push("CHART MISSING");

        return data;
    }

    public static function parse(songName:String, difficulty:String = "normal"):ChartData {
        var chartPath = Paths.chart(songName, difficulty);
        var base:ChartData = {
            strumLines: [],
            noteTypes: [],
            events: [],
            meta: null,
            scrollSpeed: 2,
            stage: "stage",
            codenameChart: true,
            fromMods: Paths.assetsTree.existsSpecific(chartPath, "TEXT", MODS)
        };

        if (!Assets.exists(chartPath)) {
            Logs.trace('Chart for song ${songName} ($difficulty) at "$chartPath" was not found.', ERROR, RED);
            return base;
        }
        var data:Dynamic = null;
        try {
            data = Json.parse(Assets.getText(chartPath));
        } catch(e) {
            Logs.trace('Could not parse chart for song ${songName} ($difficulty): ${Std.string(e)}', ERROR, RED);
        }

        if (Reflect.hasField(data, "codenameChart") && Reflect.field(data, "codenameChart") == true) {
            return cast data;
        } else {
            // base fnf chart parsing
            var data:SwagSong = data;
            if (Reflect.hasField(data, "song")) {
                var field:Dynamic = Reflect.field(data, "song");
                if (!(field is String))
                    data = field;
            }

            base.scrollSpeed = data.speed;
            base.stage = data.stage;

            base.strumLines.push({
                characters: [data.player2],
                opponent: true,
                position: "dad",
                notes: []
            });
            base.strumLines.push({
                characters: [data.player1],
                opponent: false,
                position: "boyfriend",
                notes: []
            });
            if (data.gf != "none") {
                base.strumLines.push({
                    characters: [data.gf != null ? data.gf : "gf"],
                    opponent: true,
                    position: "girlfriend",
                    notes: [],
                    visible: false,
                    strumLinePos: 0.5
                });
            }

            var camFocusedBF:Bool = false;
            var beatsPerMesure:Float = data.beatsPerMesure.getDefault(4);
            var curBPM:Float = data.bpm;
            var curTime:Float = 0;
            var curCrochet:Float = ((60 / curBPM) * 1000);

            if (data.notes != null) for(section in data.notes) {
                if (section == null) {
                    curTime += curCrochet * beatsPerMesure;
                    continue; // Yoshi Engine charts crash fix
                }

                if (camFocusedBF != (camFocusedBF = section.mustHitSection)) {
                    base.events.push({
                        time: curTime,
                        type: CAM_MOVEMENT,
                        params: [camFocusedBF ? 1 : 0]
                    });
                }

                if (section.sectionNotes != null) for(note in section.sectionNotes) {
                    if (note[1] < 0) continue;

                    var daStrumTime:Float = note[0];
				    var daNoteData:Int = Std.int(note[1] % 8);
                    var daNoteType:Int = Std.int(note[1] / 8);
                    var gottaHitNote:Bool = daNoteData >= 4 ? !section.mustHitSection : section.mustHitSection;

                    if (note.length > 2) {
                        if (note[3] is Int)
                            daNoteType = addNoteType(base, data.noteTypes[Std.int(note[3])-1]);
                        else if (note[3] is String)
                            daNoteType = addNoteType(base, note[3]);
                    } else {
                        daNoteType = addNoteType(base, data.noteTypes[daNoteType-1]);
                    }

                    
                    base.strumLines[gottaHitNote ? 1 : 0].notes.push({
                        time: daStrumTime,
                        id: daNoteData % 4,
                        type: daNoteType,
                        sustainLength: note[2]
                    });
                }

                if (section.changeBPM && section.bpm != curBPM) {
                    // TODO: BPM CHANGE EVENT
                    curCrochet = ((60 / (curBPM = section.bpm)) * 1000);
                }

                curTime += curCrochet * beatsPerMesure;
            }
        }

        if (base.meta == null)
            base.meta = loadChartMeta(songName, difficulty);
        return base;
    }

    private static function addNoteType(chart:ChartData, noteTypeName:String):Int {
        switch(noteTypeName.trim()) {
            case "Default Note" | null | "":
                return 0;
            default:
                var index = chart.noteTypes.indexOf(noteTypeName);
                if (index > -1)
                    return index+1;
                chart.noteTypes.push(noteTypeName);
                return chart.noteTypes.length;
        }
    }
}

typedef ChartData = {
    public var strumLines:Array<ChartStrumLine>;
    public var events:Array<ChartEvent>;
    public var meta:ChartMetaData;
    public var codenameChart:Bool;
    public var stage:String;
    public var scrollSpeed:Float;
    public var fromMods:Bool;
    public var noteTypes:Array<String>;
}

typedef ChartMetaData = {
    public var name:String;
    public var bpm:Float;
    public var ?displayName:String;
    public var ?beatsPerMesure:Float;
    public var ?stepsPerBeat:Float;
    public var ?needsVoices:Bool;
    public var ?icon:String;
    public var ?color:Dynamic;
	public var ?difficulties:Array<String>;
	public var ?coopAllowed:Bool;
	public var ?opponentModeAllowed:Bool;

    // NOT TO BE EXPORTED
	public var ?parsedColor:FlxColor;
}

typedef ChartStrumLine = {
    var characters:Array<String>;
    var opponent:Bool;
    var notes:Array<ChartNote>;
    var position:String;
    var ?strumLinePos:Float; // 0.25 = default opponent pos, 0.75 = default boyfriend pos
    var ?visible:Null<Bool>;
}

typedef ChartNote = {
    var time:Float; // time at which the note will be hit (ms)
    var id:Int; // strum id of the note
    var type:Int; // type (int) of the note
    var sustainLength:Float; // sustain length of the note (ms)
}

typedef ChartEvent = {
    var time:Float;
    var type:ChartEventType;
    var params:Array<Dynamic>;
}

@:enum
abstract ChartEventType(Int) from Int to Int {
    /**
     * CUSTOM EVENT
     * Params:
     *  - Function Name (String)
     *  - Function Parameters...
     */
    var CUSTOM = -1;
    /**
     * NO EVENT, MADE FOR UNKNOWN EVENTS / EVENTS THAT CANNOT BE PARSED
     */
    var NONE = 0;
    /**
     * CAMERA MOVEMENT EVENT
     * Params:
     *  - Target Strumline ID (Int)
     */
    var CAM_MOVEMENT = 1;

    /**
     * BPM CHANGE EVENT
     * Params:
     *  - Target BPM (Float)
     */
    var BPM_CHANGE = 2;
    /**
     * ALT ANIM TOGGLE
     * Params:
     *  - Strum Line which is going to be toggled (Int)
     *  - Whenever its going to be toggled or not (Bool)
     */
    var ALT_ANIM_TOGGLE = 3;
}