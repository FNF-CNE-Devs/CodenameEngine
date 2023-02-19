package funkin.chart;

import funkin.system.Song.SwagSong;
import haxe.Json;
import openfl.utils.Assets;

class Chart {
    public static function parse(songName:String, difficulty:String = "normal"):ChartData {
        var base:ChartData = {
            strumLines: [],
            events: [],
            meta: {
                name: songName,
                bpm: 0
            },
            stage: "stage",
            codenameChart: true
        };
        var chartPath = Paths.chart(songName, difficulty);
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

            base.stage = data.stage;
            base.meta.name = data.song;
            base.meta.bpm = data.bpm;

            base.strumLines.push({
                characters: [data.player2],
                opponent: true,
                notes: []
            });
            base.strumLines.push({
                characters: [data.player1],
                opponent: false,
                notes: []
            });

            var camFocusedBF:Bool = false;
            var beatsPerMesure:Float = data.beatsPerMesure.getDefault(4);
            var curBPM:Float = data.bpm;
            var curTime:Float = 0;
            var curCrochet:Float = ((60 / curBPM) * 1000);

            if (data.notes != null) for(section in data.notes) {
                if (section == null) continue; // Yoshi Engine charts crash fix

                if (camFocusedBF != (camFocusedBF = section.mustHitSection)) {
                    // TODO: auto-add event for cam movement
                    base.events.push({
                        time: curTime,
                        type: CAM_MOVEMENT,
                        params: [camFocusedBF ? 1 : 0]
                    });
                }

                if (section.sectionNotes != null) for(note in section.sectionNotes) {
                    var daStrumTime:Float = note[0];
				    var daNoteData:Int = Std.int(note[1] % 8);
                    var daNoteType:Int = Std.int(note[1] / 8);
                    var gottaHitNote:Bool = daNoteData >= 4 ? !section.mustHitSection : section.mustHitSection;
                    
                    base.strumLines[gottaHitNote ? 1 : 0].notes.push({
                        time: daStrumTime,
                        id: daNoteData % 4,
                        type: daNoteType,
                        sustainLength: note[2]
                    });
                }

                if (section.changeBPM && section.bpm != curBPM) {
                    // TODO: BPM CHANGE EVENT
                    curCrochet = ((60 / section.bpm) * 1000);
                }

                curTime += curCrochet * beatsPerMesure;
            }
        }
        return base;
    }
}

typedef ChartData = {
    public var strumLines:Array<ChartStrumLine>;
    public var events:Array<ChartEvent>;
    public var meta:ChartMetaData;
    public var codenameChart:Bool;
    public var stage:String;
}

typedef ChartMetaData = {
    public var name:String;
    public var bpm:Float;
    public var ?icon:String;
    public var ?color:Dynamic;
	public var ?difficulties:Array<String>;
	public var ?coopAllowed:Bool;
	public var ?opponentModeAllowed:Bool;
}

typedef ChartStrumLine = {
    var characters:Array<String>;
    var opponent:Bool;
    var notes:Array<ChartNote>;
    var ?strumLinePos:Float; // 0.25 = default opponent pos, 0.75 = default boyfriend pos
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