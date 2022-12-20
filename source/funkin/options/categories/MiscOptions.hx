package funkin.options.categories;

import flixel.FlxG;

class MiscOptions extends OptionsScreen {
    public override function create() {
        options = [
            #if UPDATE_CHECKING
            new Checkbox(
                "Enable Beta Updates",
                "If checked, will also include beta (prereleases) updates in the update checking.",
                "betaUpdates"),
            new TextOption(
                "Check for Updates",
                "Select this option to check for new engine updates.",
                function() {
                    var report = funkin.updating.UpdateUtil.checkForUpdates();
                    if (report.newUpdate) {
                        FlxG.switchState(new funkin.updating.UpdateAvailableScreen(report));
                    } else {
                        CoolUtil.playMenuSFX(2);
                        updateDescText("No update found.");
                    }
            }),
			#end
            new TextOption(
                "Reset Save Data",
                "Select this option to reset save data. This will remove all of your highscores",
                function() {
                    // TODO!!
            })
        ];
        super.create();
    }
}