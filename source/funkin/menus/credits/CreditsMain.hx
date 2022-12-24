package funkin.menus.credits;

import flixel.addons.transition.FlxTransitionableState;
import funkin.options.OptionsScreen;
import flixel.FlxG;
import funkin.options.type.*;

class CreditsMain extends OptionsScreen {
    public override function create() {
        options = [
            // TODO: Custom Credits
            new TextOption("Codename Engine", "Select this to see all of the contributors of the engine!", function() {
                FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
                FlxG.switchState(new CreditsCodename());
            }),
            new TextOption("Friday Night Funkin'", "Select this to open the itch.io page of the original game to donate!", function() {
                #if linux
                Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
                #else
                FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
                #end
            })
        ];
        super.create();
    }
}