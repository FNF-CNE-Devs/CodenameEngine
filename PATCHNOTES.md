# The Charter Update
## All major chart editors are finished as of this update (finally...)
## Engine goes from alpha to beta state : D

<details>
  <summary><h2>Patch Notes</h2></summary>

- CHARTER FEATURES
	- BIG BOY FEATURES
		- Note Types in charter
		- New Difficulty is now implemented
		- Snaps for notes/events
		- Multiple Vocals Support
		- Playback speed in charter
		- New SEXY assets by paige and fushi!!!! (and lunar, does 16x16 even count??? 😭)
		- NEW EVENTS (Camera events, play animation, scroll speed change)
		- Events window is now scrollable (more events, more room)
		- Custom Properities in Meta (Editable in Charter :D)
	- SMALLER BUT STILL COOL
		- Multiple Icons now show for strumlines with multiple characters
		- Note hoverer to show where the note your going to place is going to go
		- UI got some slight reworks (top bar/elements)
		- Event files can be packed together (image/script/json all in a .pack)
		- Optimized notes in charter (Faster loading, can handle a billion now so cool neo!!)
		- editor Song pos now stays the same even after playtesting
		- Other shit i forgot all of it 😭
	- BUG FIXES:
		- DUPILACATED EVENTS NOW WORK!!!
		- Song position line no longer gitters
		- UNDOs are more stable now
		- Drags work much better
		- Freezes fixed (deleting strumlines)
- ENGINE FEATURES
	- BIG BOY FEATURES
		- Position custom characters in stage xml
		- Asesprite sprites support
		- Edit Draw call directly from the sprite (sprite.onDraw = (spr:FlxSprite) -> {spr.draw();})
		- Scripted Asset Libararies (so cool)
		- Proper addon support (multiple addons at the same time)
		- MusicBeatTransition is more scriptable
		- Moddable Game Over Event!!
		- Reworked Lagless Credits Codename Engine's Contributors Menu
		- New Credit Mode for GitHub accounts (aswell lagless) in Mod Credits (First gets the data normally, if fails uses the ratelimited api)
		- MANY OG GAME WEEK STUFF!! (still wip and softcoded!)
		- Senpai Cutscene got reworked! (https://github.com/FNF-CNE-Devs/CodenameEngine/assets/87421482/3b3f32fc-78d1-40fa-8398-776554cab1d6)
		- Thorns got reworked with a cool chromatic aberration effect! (https://github.com/FNF-CNE-Devs/CodenameEngine/assets/87421482/73d9f7c5-1c9c-407e-baf0-e8e2c381ecbb)
		- Winter Horrorland got reworked with a bloody vignette effect! (https://github.com/FNF-CNE-Devs/CodenameEngine/assets/87421482/1e10c3e2-32dc-4de2-b31a-d9d577d516da - https://github.com/FNF-CNE-Devs/CodenameEngine/assets/87421482/cad852c3-1ee2-409e-a70e-b3571ab5cf7b)
	- SMALLER BUT STILL COOL
		- Ability to set Controls.hx variables
		- You can now easily check if a cutscene was seen (And make it auto play or not; Check startCutscene() code for more details in PlayState)
		- onScriptCreated event in global.hx
		- Addons priority (being able to load addons before or after a mod)
		- Added Script.fromString to add scripts without pescky new files!!
		- 9 Splice Sprites can render smaller than their atlas
		- Able to turn off gitaroo easter egg (finally...)
		- Auto complete in certain text fields (characters/stages/notetypes)
	- HSCRIPT FEATURES:
		- Added is for checking var type
		- Maps iterator for (key=>value in map)
		- FIXED CRASH ON EMPTY SCRIPTS!!!!!
- BUG FIXES
	- Fix events to be more stable
	- Fix for onBeat sprites type with also customizable beat intervals and offset (and decide if also skipping negative beats so for example before the song starts)
	- Fix for pressing F5 in editor breaking it
	- Fix when getting GitHub data and a redirect happens
	- Fix for healthbar incorrectly colored in opponent mode
	- Lots and lots of grammar and wording fixes (so true bro -lunar)
	- Lots and lots of other optimizations made
	- Video cutscenes are ALOT more stable (thanks majigsaw :D)
	- 3D now works (so cool i love away3d in 2024)
- CHANGES
	- onDestroy has been renamed to destroy in all instances
	- Strumline Pos X in editors is now a ratio (0.25 for bf, 0.75 for dad)
	- BY DEFAULT when in Story Mode, the arrows tween in happens only if there was a transition
	- onBeatHit renamed to beatHit in gameover substate (stepHit added)
	- Alt Animation Events can now control both poses and idle (may need to be readded in pre existing charts)
	- Autocomplete textboxes added 
	- Some other shit idk ill add it whenever someone tells me backward compat is broke 💔
</details>

thanks so much for the support and always being there cne community, it really does mean alot to us < 3
