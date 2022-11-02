package funkin.options.categories;

import funkin.windows.WindowsAPI;

class DebugOptions extends OptionsScreen {
    public override function create() {
        options = [
            #if windows
            new TextOption(
                "Show Console",
                "Select this to show the debug console, which contains log information about the game.",
                function() {
                    WindowsAPI.allocConsole();
                }),
            #end
        ];
        super.create();
    }
}