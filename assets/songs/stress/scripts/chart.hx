import openfl.utils.Assets;

function onPostGenerateStrums() {
    strumLine = new StrumLine([gf], -1, true, controls);
    players.push(strumLine);
    strumLine.generateStrums();
}

function onNoteCreation(event)
    if (event.noteType != null || event.note.noteTypeID > 0)
        event.note.strumLineID = 2;

var strumLine:StrumLine;

function postCreate() {
    generateNotes(CoolUtil.parseJson(Paths.chart('stress', 'picospeaker')).song);
}

function onStrumCreation(event) {
    if (event.player == 3) {
        event.cancelAnimation();
        event.strum.alpha = 0;
        event.strum.visible = false;
    }
}