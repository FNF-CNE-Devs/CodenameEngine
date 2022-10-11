trace("Hello, World!");

function createPost() {
    // globalOffset.y -= 150;
}

function update(elapsed:Float) {
    // y = y + Math.sin(Conductor.songPosition / 1000 * Math.PI) * 125 * elapsed;
}

function onGetCamPos(deezNuts:Dynamic) {
    if (animation.curAnim == null) return;
    switch(animation.curAnim.name) {
        case "singUP":
            deezNuts.y -= 25;
        case "singDOWN":
            deezNuts.y += 25;
        case "singLEFT":
            deezNuts.x -= 25;
        case "singRIGHT":
            deezNuts.x += 25;
    }
}