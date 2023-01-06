# Friday Night Funkin' - Codename Engine (WIP)

## PLEASE NOTE - THIS IS STILL IN A BETA STATE

Early alpha of Codename Engine, known issues:
- Some options are missing
- Week 5 has no monster animation
- Week 6 still have no dialogue
- Week 7 have no running tankman

Build instructions are below. Press TAB on the main menu to switch mods.

Also, `lime test windows` uses the source assets folder instead of the export one.

## CREDITS
- Credits to [Ne_Eo](https://twitter.com/Ne_Eo_Twitch) and the [3D-HaxeFlixel](https://github.com/lunarcleint/3D-HaxeFlixel) repository for Away3D Flixel support
- Credits to Smokey555 for the fancy Animate Atlas code (might be replaced soon)

## HOW TO BUILD
- Install the [latest version of Haxe](https://haxe.org/download/)
- Install everything mentioned here for your platform: [`Windows`](https://lime.openfl.org/docs/advanced-setup/windows/), [`Linux`](https://lime.openfl.org/docs/advanced-setup/linux/), [`MacOS`](https://lime.openfl.org/docs/advanced-setup/macos/)
- Run `update.bat` to install/update all libraries needed for the engine.
    - If you're using another operating system, execute `haxe -cp update -D analyzer-optimize -main Update --interp` in a terminal.
- Run `lime test windows` to compile the game (may take a long time)
