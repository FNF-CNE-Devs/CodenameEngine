package funkin.desktop;

import openfl.geom.Rectangle;
import flixel.FlxObject;
import lime.app.Application;
import openfl.display.BitmapData;
import flixel.system.scaleModes.BaseScaleMode;
import flixel.system.scaleModes.FixedScaleAdjustSizeScaleMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import funkin.desktop.editors.HelloWorld;
import funkin.desktop.windows.*;
import funkin.desktop.theme.Theme;

class DesktopMain extends MusicBeatState {
    public var oldScaleMode:BaseScaleMode;
    public var wallpaper:FlxSprite;
    public var screenSize:FlxPoint;

    public var windows:WindowGroup<Window>;

    public static var instance:DesktopMain;

    public var mouseInput:MouseInput = new MouseInput();

    public static var theme:Theme = null;

    public override function create() {
        super.create();

        theme = Theme.loadFromAssets(Paths.getPath('images/desktop/ui.xml', TEXT, null));
        instance = this;
        
        FlxG.mouse.useSystemCursor = FlxG.mouse.visible = true;
        oldScaleMode = FlxG.scaleMode;
        FlxG.scaleMode = new FixedScaleAdjustSizeScaleMode(false, false);

        wallpaper = new FlxSprite();
        #if windows
        try {
            wallpaper.loadGraphic(BitmapData.fromFile('${Sys.getEnv("AppData")}\\Microsoft\\Windows\\Themes\\TranscodedWallpaper'));
        } catch(e) #end wallpaper.loadGraphic(Paths.image("menuBG"));
        wallpaper.scrollFactor.set(0, 0); // anchor at top left
        wallpaper.antialiasing = true;
        add(wallpaper);

        screenSize = new FlxPoint(-1, -1);

        windows = new WindowGroup<Window>();
        add(windows);
    }

    public override function update(elapsed:Float) {
        mouseInput.set(FlxG.mouse.pressed, FlxG.mouse.justPressed, FlxG.mouse.justReleased);

        super.update(elapsed);

        if (screenSize.x != FlxG.width || screenSize.y != FlxG.height) {
            screenSize.set(FlxG.width, FlxG.height);
            updateScreenRes();
        }

        // debug window
        if (FlxG.keys.justPressed.SPACE)
            windows.add(new Window(new HelloWorld()));
    }

    public function updateScreenRes() {
        // update wallpaper
        wallpaper.setUnstretchedGraphicSize(FlxG.width, FlxG.height);
    }

    public override function destroy() {
        super.destroy();
        FlxG.scaleMode = oldScaleMode;
        FlxG.mouse.useSystemCursor = FlxG.mouse.visible = false;

        // TODO: switch back while using config
        FlxG.resizeGame(1280, 720);
    }

    public function focusWindow(window:Window) {
        windows.remove(window, true);
        windows.add(window);
        layerCameras();
    }

    public function layerCameras() {
        for(win in windows.members) {
            FlxG.cameras.remove(win.windowCaptionCamera, false);
            for(e in win.windowCameras) FlxG.cameras.remove(e.camera, false);
        }
        for(win in windows.members) {
            FlxG.cameras.add(win.windowCaptionCamera, false);
            for(e in win.windowCameras) FlxG.cameras.add(e.camera, false);
        }
    }
}

class MouseInput {
    public var pressed:Bool = false;
    public var justPressed:Bool = false;
    public var justReleased:Bool = false;
    private var __cancelled:Bool = false;

    public function cancel() {
        pressed = justPressed = justReleased = false;
        __cancelled = true;
    }

    public function new() {}

    public function set(pressed:Bool, justPressed:Bool, justReleased:Bool) {
        this.pressed = pressed;
        this.justPressed = justPressed;
        this.justReleased = justReleased;
        this.__cancelled = false;
    }

    public function overlaps(spr:FlxObject, ?camera:FlxCamera) {
        return overlapsRect(spr, new Rectangle(spr.x, spr.y, spr.width, spr.height), camera);
        // return FlxG.mouse.overlaps(spr, camera);
    }

    public function overlapsRect(spr:FlxBasic, rect:Rectangle, ?camera:FlxCamera) {
        if (__cancelled) return false;
        if (camera == null) camera = FlxG.camera;
        var pos = FlxG.mouse.getScreenPosition(camera);
        
        return ((pos.x > rect.x) && (pos.x < rect.x + rect.width)) && ((pos.y > rect.y) && (pos.y < rect.y + rect.height));
    }
}