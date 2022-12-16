package funkin.updating;

import funkin.updating.UpdateUtil.UpdateCheckCallback;

class UpdateScreen extends MusicBeatState {
    public var updater:AsyncUpdater;

    public function new(check:UpdateCheckCallback) {
        super(false);
        updater = new AsyncUpdater(check.updates);
    }

    public override function create() {
        super.create();
        updater.execute();
    }
}