# Friday Night Funkin' - Codename Engine (WIP)

## PLEASE NOTE - THIS IS STILL IN A BETA STATE
### Mods created with beta versions of Codename may not be compatible with the release version
Known issues in the beta:
- Some options are missing

Build instructions are below. Press TAB on the main menu to switch mods.

Also, the command `.\cne test` uses the source assets folder instead of the export one for easier development (Although you can still use `lime test windows` normally).

## Codename Engine

Codename Engine is a new Friday Night Funkin' Engine aimed at simplifying modding, along with extensiblity and ease of use.<br>
Make sure to read the wiki and join the Discord server linked there!<br>
#### It includes many new features, as seen [here](FEATURES.md)<br>
#### Wanna see the new features added in the most recent update? Click [here](PATCHNOTES.md)<br>

## How to download

Latest builds for the engine can be found in the [Actions](https://github.com/YoshiCrafter29/CodenameEngine/actions) tab.<br>
In the future (when the engine won't be a WIP anymore) we're gonna also publish the engine on platforms like Gamebanana; stay tuned!

<details>
  <summary><h2>How to build</h2></summary>

> **Open the instructions for your platform**
<details>
    <summary>Windows</summary>

##### Tested on Windows 10 21H2
1. Install [version 4.2.5 of Haxe](https://haxe.org/download/version/4.2.5/).
2. Download [Visual Studio Build Tools](https://aka.ms/vs/17/release/vs_BuildTools.exe)
3. Wait for the Visual Studio Installer to install
4. On the Visual Studio installer screen, go to the "Individual components" tab and only select those options:
    - MSVC v143 VS 2022 C++ x64/x86 build tools (Latest)
    - Windows 10/11 SDK (any works)
5. This is what your Installation details panel should look like. Once correct, press "Install".
    - ⚠ This will download around 1.07 GB of data from the internet, and will require around 5.5 GB of available space on your computer.

<p align="center">
<img src="https://github.com/YoshiCrafter29/CodenameEngine/blob/main/art/github/windows-installation-details.png?raw=true" />
</p>

6. Once you finish downloading those components, download and install [`git-scm`](https://git-scm.com/download/win).
    - Leave all installation options as default.
7. Run `update.bat` using cmd or double-clicking it, and wait for the libraries to install.
8. Once the libraries are installed, run `haxelib run lime test windows` to compile and launch the game (may take a long time)
    - ℹ You can run `haxelib run lime setup` to make the lime command global, allowing you to execute `lime test windows` directly.
</details>
<details>
    <summary>Linux</summary>

##### Requires testing
1. Install [version 4.2.5 of Haxe](https://haxe.org/download/version/4.2.5/).
2. Install `g++`, if not present already.
3. Download and install [`git-scm`](https://git-scm.com/download/linux).
4. Open a terminal in the Codename Engine source folder, and run `update.sh`.
5. Once the libraries are installed, run `haxelib run lime test linux` to compile and launch the game (may take a long time)
    - ℹ You can run `haxelib run lime setup` to make the lime command global, allowing you to execute `lime test linux` directly.
</details>
<details>
    <summary>MacOS</summary>

##### Requires testing
1. Install [version 4.2.5 of Haxe](https://haxe.org/download/version/4.2.5/).
2. Install `Xcode` to allow C++ app building.
3. Download and install [`git-scm`](https://git-scm.com/download/mac).
4. Open a terminal in the Codename Engine source folder, and run `update.sh`.
5. Once the libraries are installed, run `haxelib run lime test mac` to compile and launch the game (may take a long time)
    - ℹ You can run `haxelib run lime setup` to make the lime command global, allowing you to execute `lime test mac` directly.
</details>
</details>

<details>
  <summary><h2>What can you do or not do</h2></summary>

  ### You can:
  - Download and play the engine with its mods and modpacks
  - Mod and fork the engine (without using it for illicit purposes)
  - Contribute to the engine (for example through *Pull Requests*, *Issues*, etc)
  - Create a sub engine with Codename Engine as **TEMPLATE** with **CREDITS** (for example leaving the *credits menu submenu with the GitHub contributors* and putting the *[main devs](https://github.com/FNF-CNE-Devs)* in a *README* specifying that it's a *sub engine from Codename Engine*)
  - Release excutable mods that use Codename Engine as source (Specifing that uses Codename Engine by for example the same way written above this)
  - Release modpacks

  ### You can't:
  - Create a *side/new/etc* engine (or mod that doesn't use Codename Engine) using Codename Engine's code
  - Steal code from Codename Engine for another different project that is not Codename Engine related (Codename Engine mods excluded) without properly crediting
  - Release the entire Codename Engine on platforms (Mods that use Codename Engine as source are fine, if it's specified even better)

  #### *If you need more info or feel like asking to do something which is not listed here, ask us directly on our discord (linked in the wiki)!*
</details>

<details>
  <summary><h2>Credits</h2></summary>

- Credits to [Ne_Eo](https://twitter.com/Ne_Eo_Twitch) and the [3D-HaxeFlixel](https://github.com/lunarcleint/3D-HaxeFlixel) repository for Away3D Flixel support
- Credits to the [FlxAnimate](https://github.com/Dot-Stuff/flxanimate) team for the Animate Atlas support
- Credits to Smokey555 for the backup Animate Atlas to spritesheet code
- Credits to MAJigsaw77 for [hxvlc](https://github.com/MAJigsaw77/hxvlc) for video cutscene/mp4 support
- Credits to Aidan63 for [discord-rpc](https://github.com/Aidan63/linc_discord-rpc) for discord rpc integration
</details>
