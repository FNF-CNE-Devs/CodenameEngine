package funkin.options.categories;

import funkin.windows.WindowsAPI;

class DebugOptions extends OptionsScreen {
    public override function new() {
        super();
        #if windows
        add(new TextOption(
            "Show Console",
            "Select this to show the debug console, which contains log information about the game.",
            function() {
                WindowsAPI.allocConsole();
            }));
        #end
    }
}