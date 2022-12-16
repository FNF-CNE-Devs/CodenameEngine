package funkin.updating;

import funkin.updating.UpdateUtil.UpdateCheckCallback;

class UpdateScreen extends MusicBeatState {
    public var updater:Updater;

    public function new(check:UpdateCheckCallback) {
        super(false);
        updater = new AsyncUpdater(check);
    }

    public override function create() {
        super.create();
        Main.execAsync(installUpdates);        
    }
}