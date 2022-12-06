function create() {
    importScript("data/scripts/pixel");
    pixelNotesForBF = false;
    enablePixelUI = true;
    enableCameraHacks = false;
}

function postCreate() {
    for(i in 0...6) {
        var name = "tank" + Std.string(i);
        stage.getSprite(name).visible = false;
    }
}

function postUpdate(elapsed) {
    // var sin = Math.sin(curBeatFloat * Math.PI / 2);

    // camGame.angle = sin * -15;

    if (curSection != null)
        defaultCamZoom = curSection.mustHitSection ? 0.9 : 0.5;
}