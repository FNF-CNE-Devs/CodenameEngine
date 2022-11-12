var dir = 2;

function onDance(event) {
    event.cancel();
    
    playAnim("idle" + Std.string(dir), true, "DANCE");
}

function onPlaySingAnim(event) {
    dir = FlxG.random.int(0, 1) + (event.direction == 0 ? 1 : 3);
    event.cancel();

    playAnim("shoot" + Std.string(dir), true);
}

function update(elapsed) {
    if (animation.curAnim == null || (animation.curAnim.name.substr(0, 5) == "shoot" && animation.curAnim.finished))
        dance();
}