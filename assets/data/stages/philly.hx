var curColor:Int = 0;
var colors = [
    0xFF31A2FD,
    0xFF31FD8C,
    0xFFFB33F5,
    0xFFFD4531,
    0xFFFBA633
];

function create() {
    light.color = colors[curColor];
}

function beatHit(curBeat:Int) {
    if (curBeat % 4 == 0) {
        // switches color
        var newColor = FlxG.random.int(0, colors.length-2);
        if (newColor >= curColor) newColor++;
        curColor = newColor;
        light.color = colors[curColor];
    }
}

function update(elapsed:Float) {
    if (Conductor.songPosition > 0)
        light.alpha = 1 - (FlxEase.cubeIn((curBeatFloat / 4) % 1) * 0.85);
    else 
        light.alpha = 0;
}