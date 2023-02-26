package funkin.chart;

import funkin.system.Song.SwagSong;

class BaseGameParser {
    public static function parse(data:Dynamic, result:ChartData) {
        // base fnf chart parsing
        var data:SwagSong = data;
        if (Reflect.hasField(data, "song")) {
            var field:Dynamic = Reflect.field(data, "song");
            if (!(field is String))
                data = field;
        }

        result.scrollSpeed = data.speed;
        result.stage = data.stage;

        result.strumLines.push({
            characters: [data.player2],
            opponent: true,
            position: "dad",
            notes: []
        });
        result.strumLines.push({
            characters: [data.player1],
            opponent: false,
            position: "boyfriend",
            notes: []
        });
        if (data.gf != "none") {
            result.strumLines.push({
                characters: [data.gf != null ? data.gf : "gf"],
                opponent: true,
                position: "girlfriend",
                notes: [],
                visible: false,
                strumLinePos: 0.5
            });
        }

        result.meta.bpm = data.bpm;

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
                result.events.push({
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
                        daNoteType = Chart.addNoteType(result, data.noteTypes[Std.int(note[3])-1]);
                    else if (note[3] is String)
                        daNoteType = Chart.addNoteType(result, note[3]);
                } else {
                    daNoteType = Chart.addNoteType(result, data.noteTypes[daNoteType-1]);
                }

                
                result.strumLines[gottaHitNote ? 1 : 0].notes.push({
                    time: daStrumTime,
                    id: daNoteData % 4,
                    type: daNoteType,
                    sLen: note[2]
                });
            }

            if (section.changeBPM && section.bpm != curBPM) {
                // TODO: BPM CHANGE EVENT
                curCrochet = ((60 / (curBPM = section.bpm)) * 1000);
            }

            curTime += curCrochet * beatsPerMesure;
        }
    }
}