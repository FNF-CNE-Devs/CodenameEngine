var healTween:FlxTween;

function onPlayerHit(e) {
    if (e.noteType == "Heal Note"){
        health += .125;
        boyfriend.color = FlxColor.GREEN;
        healTween = FlxTween.color(boyfriend, 1, FlxColor.GREEN, FlxColor.WHITE, {ease: FlxEase.quintOut, onComplete: function(twn:FlxTween){healTween = null;}});
    }
}

function onPlayerMiss(e) {
	if (e.noteType == "Heal Note"){
		e.cancel();
		deleteNote(e.note);
	}
}

function onDadHit(e) {
    if (e.noteType == "Heal Note"){
        health -= .125;
        dad.color = FlxColor.GREEN;
        healTween = FlxTween.color(dad, 1, FlxColor.GREEN, FlxColor.WHITE, {ease: FlxEase.quintOut, onComplete: function(twn:FlxTween){healTween = null;}});
    }
}

function onNoteCreation(e) {
    if (e.noteType == "Heal Note"){
		e.noteSprite = "game/notes/HEAL_note_assets";
		e.note.updateHitbox();
	}
}

function postCreate()
    if (healTween != null)
        healTween.cancel();