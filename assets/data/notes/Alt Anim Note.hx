import haxe.io.Path;

function onNoteHit(event) {
	if(event.note.noteType == Path.withoutExtension(__script__.fileName)) {
		event.animSuffix = "-alt";
	}
}