package funkin.game;

import flixel.FlxCamera;
import funkin.system.Conductor;
import flixel.group.FlxGroup.FlxTypedGroup;

class NoteGroup extends FlxTypedGroup<Note> {
    var __loopSprite:Note;
    var i:Int = 0;
    public override function update(elapsed:Float) {
        i = 0;
        __loopSprite = null;
        while(i < length) {
            __loopSprite = members[i];
            if (__loopSprite == null || !__loopSprite.exists || !__loopSprite.active) continue;
            if (__loopSprite.strumTime - Conductor.songPosition > 1500)
                break;
            __loopSprite.update(elapsed);
            i++;
        }
    }

    public override function draw() {
        @:privateAccess var oldDefaultCameras = FlxCamera._defaultCameras;
		@:privateAccess if (cameras != null) FlxCamera._defaultCameras = cameras;
		
        i = 0;
        __loopSprite = null;

        while(i < length) {
            __loopSprite = members[i];
            if (__loopSprite == null || !__loopSprite.exists || !__loopSprite.visible) continue;
            if (__loopSprite.strumTime - Conductor.songPosition > 1500) break;
            __loopSprite.draw();
            i++;
        }

        @:privateAccess FlxCamera._defaultCameras = oldDefaultCameras;
    }

    public override function forEach(noteFunc:Note->Void, recursive:Bool = false) {
        i = 0;
        __loopSprite = null;

        while(i < length) {
            __loopSprite = members[i];
            if (__loopSprite == null || !__loopSprite.exists) continue;
            if (__loopSprite.strumTime - Conductor.songPosition > 1500) break;
            noteFunc(__loopSprite);
            i++;
        }
    }
    public override function forEachAlive(noteFunc:Note->Void, recursive:Bool = false) {
        forEach(function(note) {
            if (note.alive) noteFunc(note);
        }, recursive);
    }
    
}