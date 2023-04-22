function beatHit(curBeat) {
	if (curBeat != 79 && curBeat % 8 == 7)
		boyfriend.playAnim("hey");
}