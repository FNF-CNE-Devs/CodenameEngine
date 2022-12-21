package funkin.multitasking;

import openfl.Lib;
import openfl.display.Sprite;
import flash.events.Event;
import flixel.math.FlxPoint;
import lime.ui.WindowAttributes;
import lime.app.Application;
import lime.ui.Window;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxG;

class StateWindow extends Sprite {
    public var window:Window;
    public var state:MusicBeatState;
    public var cameras:Array<FlxCamera> = [new FlxCamera()];
    public var camerasDefault:Array<FlxCamera> = [];

    public function new(windowName:String, state:MusicBeatState) {
        super();
        
        var windowAttributes:WindowAttributes = {
            width: FlxG.width,
            height: FlxG.height,
            resizable: true
        };
        window = Application.current.createWindow(windowAttributes);
        window.title = windowName;
        window.stage.color = 0x000000;
		window.stage.scaleMode = NO_SCALE;
		window.stage.align = TOP_LEFT;
        window.onClose.add(function() {
            MultiTaskingHandler.closeWindow(this);
        });

        window.stage.addChild(this);

        state.parentWindow = this;
        this.state = state;

        beforeStateShit();
        state.create();
        state.createPost();
        afterStateShit();


    }
    
    var oldSize = FlxPoint.get(FlxG.width, FlxG.height);
    var oldCamList:Array<FlxCamera>;
    var oldCamDefaults:Array<FlxCamera>;
    var oldCam:FlxCamera;
    var oldState:FlxState;
    
    public function beforeStateShit() {
        oldSize.set(FlxG.width, FlxG.height);

        @:privateAccess {
            FlxG.width = 1280;
            FlxG.height = 720;

            oldCamDefaults = FlxG.cameras.defaults;
            oldCamList = FlxG.cameras.list;
            oldCam = FlxG.camera;

            FlxCamera._defaultCameras = FlxG.cameras.defaults = camerasDefault;
            FlxG.cameras.list = cameras;
            FlxG.camera = cameras[0];

            oldState = FlxG.game._state;
            FlxG.game._state = state;
        }
    }
    
    public function afterStateShit() {
        @:privateAccess {
            FlxG.width = Std.int(oldSize.x);
            FlxG.height = Std.int(oldSize.y);

            cameras = FlxG.cameras.list;
            camerasDefault = FlxG.cameras.defaults;

            FlxCamera._defaultCameras = FlxG.cameras.defaults = oldCamDefaults;
            FlxG.cameras.list = oldCamList;
            FlxG.camera = oldCam;
    
            oldCamList = null;
            oldCam = null;

            FlxG.game._state = oldState;
        }

    }

    public function update(elapsed:Float) {
        beforeStateShit();
        @:privateAccess
		FlxG.cameras.update(FlxG.elapsed);
        state.tryUpdate(elapsed);
        afterStateShit();
    }

    public function draw() {
        @:privateAccess {
            beforeStateShit();

            // for(c in cameras) {
            //     addChild(c.flashSprite);
            //     c.color = 0xFF0000;
            // }
            FlxG.cameras.lock();
            state.draw();
            FlxG.cameras.unlock();

            afterStateShit();
        }
    }
    /*
    public override function __enterFrame(t:Float) {
        super.__enterFrame(Std.int(t));
        @:privateAccess {
            beforeStateShit();
            for(c in cameras) {
                trace(c.x);
                trace(c.y);
                // c.bgColor = 0xFFFFFFFF;
            }
            stage.color = 0xFF0000;
            FlxG.cameras.lock();
            state.draw();
            FlxG.cameras.unlock();
            afterStateShit();
        }
    }
    */
}