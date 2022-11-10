function create() {
    importScript("data/scripts/pixel");
    pixelNotesForBF = false;
    enablePixelUI = true;
    enableCameraHacks = false;
}

function updatePost(elapsed) {
    var sin = Math.sin(curBeatFloat * Math.PI / 2);

    camGame.angle = sin * -15;
}