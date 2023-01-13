package funkin.multitasking;

import flixel.system.frontEnds.BitmapFrontEnd;
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
    public var camera:FlxCamera;
    public var cameras:Array<FlxCamera>;
    public var camerasDefault:Array<FlxCamera>;
    public var bmapFrontEnd:BitmapFrontEnd = new BitmapFrontEnd();

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

        camera = new FlxCamera();
        cameras = [camera];
        camerasDefault = [camera];

        state.parentWindow = this;
        this.state = state;

        beforeStateShit();
        state.create();
        state.createPost();
        afterStateShit();


    }
    
    var oldSize = new FlxPoint(FlxG.width, FlxG.height);
    var oldCamList:Array<FlxCamera>;
    var oldCamDefaults:Array<FlxCamera>;
    var oldCam:FlxCamera;
    var oldState:FlxState;
    var oldFrontEnd:BitmapFrontEnd;
    
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
            FlxG.camera = camera;

            oldState = FlxG.game._state;
            FlxG.game._state = state;
            

            if (this.numChildren != cameras.length) {
                trace("readding cameras...");
                while(this.numChildren > 0)
                    removeChild(getChildAt(0));

                for(c in cameras) {
                    addChild(c.flashSprite);
                    c.flashSprite.x = c.flashSprite.y = 0;
                }
            }

            oldFrontEnd = FlxG.bitmap;
            FlxG.bitmap = bmapFrontEnd;
        }
    }
    
    public function afterStateShit() {
        @:privateAccess {
            FlxG.width = Std.int(oldSize.x);
            FlxG.height = Std.int(oldSize.y);

            camera = FlxG.camera;
            cameras = FlxG.cameras.list;
            camerasDefault = FlxG.cameras.defaults;

            FlxCamera._defaultCameras = FlxG.cameras.defaults = oldCamDefaults;
            FlxG.cameras.list = oldCamList;
            FlxG.camera = oldCam;
    
            oldCamList = null;
            oldCam = null;

            FlxG.game._state = oldState;
            
            FlxG.bitmap = oldFrontEnd;
            oldFrontEnd = null;
        }

    }

    public function update(elapsed:Float) {
        
    }

    public function draw() {

    }

    
    public override function __enterFrame(t:Float) {
        @:privateAccess {
            beforeStateShit();

            FlxG.cameras.update(FlxG.elapsed);
            state.tryUpdate(FlxG.elapsed);
            
            FlxG.cameras.lock();
            state.draw();

            FlxG.cameras.render();
            FlxG.cameras.unlock();

            afterStateShit();
        }
    }
}