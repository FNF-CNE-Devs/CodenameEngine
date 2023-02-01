import openfl.utils.Assets;

function onNoteCreation(event) {
    if (event.noteType != null || event.note.noteTypeID > 0) {
        // event.note.visible = false;
        event.note.strumLineID = 2;
    }
}


var strumLine:StrumLine;

function postCreate() {
    strumLine = new StrumLine([gf], 0.5, true, controls);
    players.push(strumLine);
    strumLine.generateStrums();
    generateNotes(CoolUtil.parseJson(Paths.chart('stress', 'picospeaker')).song);

    for(s in cpuStrums)
        s.x -= FlxG.width * 0.125;
    for(s in playerStrums)
        s.x += FlxG.width * 0.125;
}

function update(elapsed) {
    camHUD.zoom /= 0.75;
}
function postUpdate(elapsed) {
    camHUD.zoom *= 0.75;
}