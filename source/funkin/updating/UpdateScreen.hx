package funkin.updating;

import flixel.FlxG;
import flixel.ui.FlxBar;
import funkin.updating.UpdateUtil.UpdateCheckCallback;

class UpdateScreen extends MusicBeatState {
    public var updater:AsyncUpdater;

    public var progressBar:FlxBar;

    public function new(check:UpdateCheckCallback) {
        super(false);
        updater = new AsyncUpdater(check.updates);
    }

    public override function create() {
        super.create();

        progressBar = new FlxBar(0, FlxG.height - 150, LEFT_TO_RIGHT, FlxG.width, 150);
        progressBar.createGradientBar([0xFF000000], [0xFF000000, 0xFF111111, 0xFF222222, 0xFF444444, 0xFF888888, -1], 1, 90);
        progressBar.setRange(0, 4);
        add(progressBar);

        updater.execute();
    }


    public override function update(elapsed:Float) {
        super.update(elapsed);
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
    }
}