//
function postCreate() {
    sayori.frames = Paths.getFrames("stages/taco/sayobounce");
    sayori.animation.addByPrefix("sayobounce", "sayobounce", 24, true);
    sayori.animation.play("sayobounce");
}