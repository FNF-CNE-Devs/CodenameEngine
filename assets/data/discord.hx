import funkin.backend.utils.DiscordUtil;

function onGameOver() {
	DiscordUtil.changePresence('Game Over', PlayState.SONG.meta.displayName + " (" + PlayState.difficulty + ")");
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
	DiscordUtil.changePresenceSince("In the Menus", null);
}

function onEditorTreeLoaded(name:String) {
	switch(name) {
		case "Character Editor":
			DiscordUtil.changePresenceSince("Choosing a Character", null);
		case "Chart Editor":
			DiscordUtil.changePresenceSince("Choosing a Chart", null);
		case "Stage Editor":
			DiscordUtil.changePresenceSince("Choosing a Stage", null);
	}
}

function onEditorLoaded(name:String, editingThing:String) {
	switch(name) {
		case "Character Editor":
			DiscordUtil.changePresenceSince("Editing a Character", editingThing);
		case "Chart Editor":
			DiscordUtil.changePresenceSince("Editing a Chart", editingThing);
		case "Stage Editor":
			DiscordUtil.changePresenceSince("Editing a Stage", editingThing);
	}
}