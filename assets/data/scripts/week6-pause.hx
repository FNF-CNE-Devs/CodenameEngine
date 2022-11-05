import funkin.ui.FunkinText;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxAxes;

var pixelScript:Script;
var pauseCam = new FlxCamera();

var bg:FlxSprite;
var hand:FlxSprite;

var texts:Array<FlxText> = [];

function create(event) {
    // cancel default pause menu!!
    event.cancel();
    event.music = "pixel/Lunchbox";

    cameras = [];

    pixelScript = game.scripts.getByName("pixel.hx");
    pixelScript.call("pixelCam", [pauseCam]);

    FlxG.cameras.add(pauseCam, false);

    pauseCam.bgColor = 0x88FF99CC;
    pauseCam.alpha = 0;

    bg = new FlxSprite(44 * 6, 14 * 6).loadGraphic(Paths.image('stages/school/pause/bg'));
    bg.scale.set(6, 6);
    bg.updateHitbox();
    bg.scale.y = 5;
    bg.cameras = [pauseCam];
    add(bg);

    text = new FlxText(0, 22 * 6, 0, "Pause", 8, false);
    confText(text);
    add(text);

    var i = 2;
    for(e in menuItems) {
        text = new FlxText(0, (22 * 6) + (i * 9 * 6), 0, e, 8, false);
        confText(text);
        add(text);
        texts.push(text);
        i++;
    }

    hand = new FlxSprite().loadGraphic(Paths.image('stages/school/ui/hand_textbox'));
    hand.scale.set(6, 6);
    hand.updateHitbox();
    add(hand);

    FlxTween.tween(bg, {"scale.y": 6}, 0.75, {ease: FlxEase.elasticOut});

    cameras = [pauseCam];

    FlxG.sound.play(Paths.sound('pixel/clickText'));
}

function confText(text) {
    text.scale.set(6, 6);
    text.updateHitbox();
    text.screenCenter(FlxAxes.X);
    text.borderStyle = FlxTextBorderStyle.OUTLINE;
    text.borderColor = 0xFF953E3E;
}

function createPost() {
}

function destroy() {
    FlxG.cameras.remove(pauseCam);
}

function update(elapsed) {
    pixelScript.call("updatePost", [elapsed]);

    pauseCam.alpha = lerp(pauseCam.alpha, 1, 0.25);

    var oldSec = curSelected;
    if (controls.DOWN_P)
        changeSelection(1, false);
    if (controls.UP_P)
        changeSelection(-1);

    if (oldSec != curSelected) {
        FlxG.sound.play(Paths.sound('pixel/pixelText'));
    }

    var curText = texts[curSelected];
    hand.setPosition(curText.x - hand.width - 12, curText.y + (text.height - hand.height) - 6);
    hand.x -= hand.x % 6;
    hand.y -= hand.y % 6;

    if (controls.ACCEPT) {
        FlxG.sound.play(Paths.sound('pixel/clickText'));
        selectOption();
    }
}

function changeSelection(change) {
    curSelected += change;

    if (curSelected < 0)
        curSelected = menuItems.length - 1;
    if (curSelected >= menuItems.length)
        curSelected = 0;
}