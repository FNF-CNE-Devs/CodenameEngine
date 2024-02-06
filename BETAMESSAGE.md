# Codename Engine v0.4.idk

### This is the first ever public release of Codename Engine **BETA**.
Shoutout to the people who stuck with us throughout the alpha and supported us! \
<br />

### Features available in this version:
## Main Features:
- ### Simple but advanced modding system!
	- Mods have been reworked to run in it's entirety instead of just limited to songs.
	- Uses an advanced scripting system based on haxe which is capable of modifying the game beyond source code.
		- Uses a system of events based on actions going on in the game allowing change of those actions to your needs. (ex. when a player hits a note, when it confirms on a menu etc.)
		- Ability to bind scripts to characters or stages.
		- Ability to bind scripts to states/menus.
		- Ability to create your own states/classes just like source code.
		- Ability to create even more advanced stuff using systems like ndll.
	- Uses a brand new song structure for cleanliness.
		- Uses a brand new chart format for optimization and extensibility.
		- Uses meta system for storing important values instead of in the chart file.
	- Characters, stages, weeks use an xml format for cleanliness.
	- Native custom shaders support.
	- Native 3D renderer.
	- Addon system for adding scripts or skins to run in any mod.
- New input system
- New accuracy and misses system, added to fix the base game UI.
- New options, including:
    - Controls rebinds (for P1 and P2)
    - Downscroll
    - Ghost Tapping
- Opponent & Co-op modes
- Memory optimisation (most of the game runs < 500mb)
    - Usage of [flxanimate](https://github.com/Dot-Stuff/flxanimate) on big sprites, such as Girlfriend to save memory.
    - You can further optimize it on certain stages by enabling `Low Memory Mode` in `Options > Appearance`.
- New volume change SFX (no more loud flixel beep, customizable)
- New FPS counter allowing you to see advanced info by pressing F3.
- **Windows only:**
    - (Windows) FNF is no longer blurry on 125-150% DPI
    - FNF auto fixes audio on state change when you plug in/out your headphones.
    - FNF auto applies dark titlebar
- **Week 7 included** with softcoded cutscenes (no MP4)
- Auto updating: Once the engine updates, a prompt will be available at launch. If you accept to update, the engine will auto install the newest version. All of the following update files will be downloaded from the GitHub releases:
    - `Update-Windows.exe` - Containing the latest Windows executable. (~60mb)
    - `Update-Assets.zip` - Every asset change from the latest version to the newest. If upgrading from even older version, all of the `Update-Assets.zip` files for the versions in between and the latest one will be downloaded.
- New assets and scripting management - **Applies both to the `assets` folder and mods.**
- Support for `hscript-improved`, a fork made to allow HScript to push moddingeven further
    - Allows for imports
    - Allows for public variables (variables shared between every script in aScriptPack such as a song scripts)
    - Allows for static variables (variabels shared between every single scriptran in this mod)
    - Allows you to use for example `boyfriend` instead of `PlayStateboyfriend` or `game.boyfriend`, for smaller and easier to comprehend code.
    - Allows you to use `@:bypassAccessor`
    - Allows you to use maps
- Usage of XML files for Characters instead of hardcoding them.
    - Animation names, prefixes, indices, etc... can be set in the XML withoutan additional line of code.
    - Offsets are automatically fixed. That means changes such as scaling,rotation, and playing as an opponent character wont break them.
- Entirely new song structure (`songs/name/`)
    - Usage of `meta.json`, which allows you to synchronize data between chartsand the Freeplay menu.
        - Charts can use their own by specifying `meta` in the JSON (Codenamecharts only)
    - Charts are now located in `songs/name/charts/`, and are named after thedifficulty `hard.json` instead of `name-hard.json`
        - Difficulties are auto-detected in case they aren't specified in the`meta.json` file.
    - Scripts are located in `songs/name/scripts/`, and only applies to thecurrent song.
        - Script that applies on every song are located in `data/charts/`.
    - Song files are now located in `songs/name/song/`. They still follow their`Inst.ogg` and `Voices.ogg` names.
        - Inst/Voices for custom difficulties can be set by naming those files`Inst-difficulty.ogg` and/or `Voices-difficulty.ogg`.
        - Song length limits
- Usage of XML files for stages. XMLs can:
    - Change camera zooms, camera offsets, etc...
    - Add elements to the stage and
        - Position them
        - Add animations
        - Change their scale
        - Change their scrollfactor
        - Change their zoomfactor
        - Turn on/off their antialiasing (on by default)
        - Change additional properties via child nodes.
    - Change boyfriend, girlfriend and dad's info
        - Moving the `<boyfriend />`, `<girlfriend />` and `<dad />` nodes willmove them in the layers
        - Adding x and y attributes to them will change their position
        - You can add positioning for custom characters by adding `<charactername="name" />`
- Usage of XML files for weeks.
    - Characters are located in `data/weeks/characters`.
    - Weeks are located in `data/weeks/weeks/`
    - If you need to rearrange the weeks in-game, you can use the `data/weeksweeks.txt` file.
- Editors for Charts and Characters (Stage coming soon)
	- Undos/Redos supported 
	- Warning on closing unsaved work
	- Clean UI (for ocd freaks)
	- Mature Chart editor (Character editor rework soon)
	- Features not found in other editors!
- Every single state & substate can be modified via HScript (`data/statesStateName.hx`)

:333333333333333333333333333333333333333333333333333333333333333333333333