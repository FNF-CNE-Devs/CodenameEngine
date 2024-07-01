# BUILDING

<details>
  <summary><h2>How to build</h2></summary>

> **Open the instructions for your platform**
<details>
    <summary>Windows</summary>

##### Tested on Windows 10 21H2
1. Install [version 4.2.5 of Haxe](https://haxe.org/download/version/4.2.5/).
2. Download and install [`git-scm`](https://git-scm.com/download/win).
    - Leave all installation options as default.
3. Run `update.bat`, located in `shell-scripts/update` using cmd or double-clicking it, and wait for the libraries to install.
4. Once the libraries are installed, run `haxelib run lime test windows` to compile and launch the game (may take a long time)
    - ℹ You can run `haxelib run lime setup` to make the lime command global, allowing you to execute `lime test windows` directly.
</details>
<details>
    <summary>Linux</summary>

##### Requires testing
1. Install [version 4.2.5 of Haxe](https://haxe.org/download/version/4.2.5/).
2. Install `g++`, if not present already.
3. Download and install [`git-scm`](https://git-scm.com/download/linux).
4. Open a terminal in the Codename Engine source folder, navigate to `shell-scripts/update` and run `update.sh`.
5. Once the libraries are installed, run `haxelib run lime test linux` to compile and launch the game (may take a long time)
    - ℹ You can run `haxelib run lime setup` to make the lime command global, allowing you to execute `lime test linux` directly.
</details>
<details>
    <summary>MacOS</summary>

##### Requires testing
1. Install [version 4.2.5 of Haxe](https://haxe.org/download/version/4.2.5/).
2. Install `Xcode` to allow C++ app building.
3. Download and install [`git-scm`](https://git-scm.com/download/mac).
4. Open a terminal in the Codename Engine source folder, navigate to `shell-scripts/update` and run `update.sh`.
5. Once the libraries are installed, run `haxelib run lime test mac` to compile and launch the game (may take a long time)
    - ℹ You can run `haxelib run lime setup` to make the lime command global, allowing you to execute `lime test mac` directly.
</details>
</details>