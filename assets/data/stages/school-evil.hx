function create() {
	importScript("data/scripts/pixel");
	isSpooky = true;

	// Make transition work between school types
	if(PlayState.smoothTransitionData?.stage == "school") PlayState.smoothTransitionData.stage = curStage;

	disableScript();
}