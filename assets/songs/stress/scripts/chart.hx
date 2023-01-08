import openfl.utils.Assets;

function onNoteCreation(event) {
    if (event.noteType != null || event.note.noteTypeID > 0) {
        event.note.visible = false;
        event.note.mustPress = false;
    }
}

function onDadHit(event) {
    if (event.noteType == "Pico Speaker Note") {
        event.character = gf;
        event.cancelStrumGlow();
    }
}

function postCreate() {
    generateNotes(CoolUtil.parseJson(Paths.chart('stress', 'picospeaker')).song);
}