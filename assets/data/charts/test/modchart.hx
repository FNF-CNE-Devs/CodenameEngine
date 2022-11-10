function create() {
    importScript("data/scripts/pixel");
    pixelNotesForBF = false;
    enablePixelUI = true;
    enableCameraHacks = false;
}

function updatePost(elapsed) {
    var sin = Math.sin(curBeatFloat * Math.PI / 2);
    var cos = Math.cos(curBeatFloat * Math.PI / 2);

    boyfriend.angle = sin * 15;
    dad.angle = sin * 15;

    camGame.angle = sin * -15;
}