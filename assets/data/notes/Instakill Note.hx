function onPlayerHit(e)
    if (e.noteType == "Instakill Note")
        health = -.1;

function onDadHit(e)
    if (e.noteType == "Instakill Note")
        health = 2.1;

function onPlayerMiss(e) {
	if (e.noteType == "Instakill Note"){
		e.cancel();
		deleteNote(e.note);
	}
}

function onNoteCreation(e) {
    if (e.noteType == "Instakill Note"){
		e.noteSprite = "game/notes/INSTAKILL_note_assets";
		e.note.updateHitbox();
	}
}