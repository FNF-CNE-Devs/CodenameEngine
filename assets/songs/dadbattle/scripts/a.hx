function postUpdate(elapsed:Float) {
	strumLines[1].notes.forEach(function(n) {
		if (n.strumTime < Conductor.songPosition)
			goodNoteHit(strumLines[1], n);
	});
}