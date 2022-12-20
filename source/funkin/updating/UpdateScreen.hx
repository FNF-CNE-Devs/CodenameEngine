package funkin.updating;

import funkin.menus.TitleState;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.ui.FlxBar;
import funkin.updating.UpdateUtil.UpdateCheckCallback;

class UpdateScreen extends MusicBeatState {
    public var updater:AsyncUpdater;

    public var progressBar:FlxBar;
    public var bf:FlxSprite;

    public var done:Bool = false;
    public var overSound:FlxSound;

    public function new(check:UpdateCheckCallback) {
        super(false);
        updater = new AsyncUpdater(check.updates);
    }

    public override function create() {
        super.create();

        progressBar = new FlxBar(0, FlxG.height - 75, LEFT_TO_RIGHT, FlxG.width, 75);
        progressBar.createGradientBar([0xFF000000], [0xFF000000, 0xFF111111, 0xFF222222, 0xFF444444, 0xFF888888, -1], 1, 90);
        progressBar.setRange(0, 4);
        add(progressBar);

        bf = new FlxSprite();
        bf.antialiasing = true;
        bf.frames = Paths.getFrames("menus/update/bf");
        bf.animation.addByPrefix("loading", "", 0, false);
        bf.animation.addByPrefix("loading-anim", "", 24, false);
        bf.animation.play("loading");
        bf.screenCenter();
        add(bf);

        overSound = FlxG.sound.load(Paths.sound('gameOverEnd'));

        updater.execute();
    }


    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (done) return;
        var prog = updater.progress;
        switch(prog.step) {
            case PREPARING:
                progressBar.value = 0;
            case DOWNLOADING_ASSETS:
                progressBar.value = 1 + ((prog.curFile-1+(prog.bytesLoaded/prog.bytesTotal)) / prog.files);
            case DOWNLOADING_EXECUTABLE:
                progressBar.value = 2 + (prog.bytesLoaded/prog.bytesTotal);
            case INSTALLING:
                progressBar.value = 3 + ((prog.curFile-1+(prog.curZipProgress.curFile/prog.curZipProgress.fileCount))/prog.files);
        }
        var rect = new FlxRect(0, (1 - (progressBar.value / 4)) * bf.frameHeight, bf.frameWidth, 0);
        rect.height = bf.frameHeight - rect.y;

        bf.clipRect = rect;
        bf.alpha = (progressBar.value / 4) * FlxG.random.float(0.70, 0.80);
        if (done = prog.done) {
            // update is done, play bf's anim
            FlxG.sound.music.stop();
            overSound.play();
            bf.animation.curAnim.frameRate = 24;
            bf.animation.play("loading-anim");
            bf.alpha = 1;
            FlxG.camera.fade(0xFF000000, overSound.length / 1000, false, function() {
                if (updater.executableReplaced) {
                    // the executable has been replaced, restart the game entirely
                    Sys.command('start /B ${updater.executableName}');
                    openfl.system.System.exit(0);
                } else {
                    // assets update, switch back to TitleState.
                    FlxG.switchState(new TitleState());
                }
            });
            bf.clipRect = null;
        }
    }
}