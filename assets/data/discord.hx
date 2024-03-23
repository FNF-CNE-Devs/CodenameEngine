function onGameOver() {
	changePresence('Game Over', PlayState.SONG.meta.displayName + " (" + PlayState.difficulty + ")");
}

function onPlayStateUpdate() {
	// Setting parent to make code cleaner
	var old = __script__.interp.scriptObject;
	__script__.interp.scriptObject = PlayState.instance;

	DiscordUtil.changeSongPresence(detailsText, (paused ? "Paused - " : "") + SONG.meta.displayName + " (" + difficulty + ")", inst, getIconRPC());

	__script__.interp.scriptObject = old;
}

function onMenuLoaded(name:String) {
	// Name is either "Main Menu", "Freeplay", "Title Screen", "Options Menu", "Credits Menu"
	changePresenceSince("In the Menus", null);
}

function onEditorTreeLoaded(name:String) {
	switch(name) {
		case "Character Editor":
			changePresenceSince("Choosing a Character", null);
		case "Chart Editor":
			changePresenceSince("Choosing a Chart", null);
		case "Stage Editor":
			changePresenceSince("Choosing a Stage", null);
	}
}

function onEditorLoaded(name:String, editingThing:String) {
	switch(name) {
		case "Character Editor":
			changePresenceSince("Editing a Character", editingThing);
		case "Chart Editor":
			changePresenceSince("Editing a Chart", editingThing);
		case "Stage Editor":
			changePresenceSince("Editing a Stage", editingThing);
	}
}