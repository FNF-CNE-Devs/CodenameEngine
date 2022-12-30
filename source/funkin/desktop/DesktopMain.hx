package funkin.desktop;

import flixel.math.FlxRect;
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
import flixel.util.FlxDestroyUtil;
import funkin.desktop.editors.*;
import funkin.desktop.windows.*;
import funkin.desktop.theme.Theme;

class DesktopMain extends MusicBeatState {
    public var oldScaleMode:BaseScaleMode;
    public var wallpaper:FlxSprite;
    public var screenSize:FlxPoint;

    public var windows:WindowGroup<Window>;

    public static var instance:DesktopMain;

    public static var currentFocus:IDesktopFocusableObject;

    public static var mouseInput:MouseInput;

    public static var theme:Theme = null;

    public static var contextMenu:ContextMenu = null;

    public static function init() {
        theme = Theme.loadFromAssets(Paths.getPath('images/desktop/ui.xml', TEXT, null));
        mouseInput = new MouseInput();

        FlxG.signals.preUpdate.add(function() {
            updateMouseInput();
        });
    }

    public override function create() {
        super.create();

        instance = this;
        
        FlxG.mouse.useSystemCursor = FlxG.mouse.visible = true;
        oldScaleMode = FlxG.scaleMode;
        FlxG.scaleMode = new FixedScaleAdjustSizeScaleMode(false, false);

        wallpaper = new FlxSprite();
        #if windows
        try {
            wallpaper.loadGraphic(BitmapData.fromFile('${Sys.getEnv("AppData")}\\Microsoft\\Windows\\Themes\\TranscodedWallpaper'));
        } catch(e) #end wallpaper.loadGraphic(Paths.image("menus/menuBG"));
        wallpaper.scrollFactor.set(0, 0); // anchor at top left
        wallpaper.antialiasing = true;
        add(wallpaper);

        screenSize = new FlxPoint(-1, -1);

        windows = new WindowGroup<Window>();
        add(windows);
    }

    private static function updateMouseInput() {
        mouseInput.set(FlxG.mouse.pressed, FlxG.mouse.justPressed, FlxG.mouse.justReleased, FlxG.mouse.pressedRight, FlxG.mouse.justPressedRight, FlxG.mouse.justReleasedRight);
    }
    
    public override function update(elapsed:Float) {
        updateMouseInput();

        if (contextMenu != null)
            contextMenu.update(elapsed);

        super.update(elapsed);


        if (screenSize.x != FlxG.width || screenSize.y != FlxG.height) {
            screenSize.set(FlxG.width, FlxG.height);
            updateScreenRes();
        }

        // debug window
        if (FlxG.keys.justPressed.SPACE)
            windows.add(new Window(new HelloWorld()));
        if (FlxG.keys.justPressed.F1)
            windows.add(new Window(new CharacterEditor('dad')));
        if (FlxG.keys.justPressed.F2)
            windows.add(new Window(new EditorPlayState()));

        FlxG.sound.enableVolumeChanges = !(currentFocus is IDesktopInputObject);
    }

    public function openWindow(content:WindowContent) {
        return windows.add(new Window(content));
    }

    public override function draw() {
        super.draw();
        if (contextMenu != null)
            contextMenu.draw();
    }

    public function updateScreenRes() {
        // update wallpaper
        wallpaper.setUnstretchedGraphicSize(FlxG.width, FlxG.height);
        for(e in windows) {
            e.onDesktopSizeChange(FlxG.width, FlxG.height);
        }
    }

    public override function destroy() {
        super.destroy();

        FlxG.sound.enableVolumeChanges = true;
        contextMenu = FlxDestroyUtil.destroy(contextMenu);

        FlxG.scaleMode = oldScaleMode;
        FlxG.mouse.useSystemCursor = FlxG.mouse.visible = false;

        // TODO: switch back while using config
        FlxG.resizeGame(1280, 720);

        if (screenSize != null)
            screenSize.put();
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

    public static function loseFocus(obj:IDesktopFocusableObject) {
        if (currentFocus == obj) {
            currentFocus.onFocusLost();
            currentFocus = null;
        }
    }

    public static function setFocus(obj:IDesktopFocusableObject) {
        if (currentFocus == obj) return;
        if (currentFocus != null)
            currentFocus.onFocusLost();
        (currentFocus = obj).onFocus();
    }

    public static function hasFocus(obj:IDesktopFocusableObject) {
        return currentFocus == obj;
    }
}

class MouseInput {
    public var pressed:Bool = false;
    public var justPressed:Bool = false;
    public var justReleased:Bool = false;
    public var pressedRight:Bool = false;
    public var justPressedRight:Bool = false;
    public var justReleasedRight:Bool = false;
    public var screenPos:FlxPoint = null;
    private var __cancelled:Bool = false;

    public function cancel() {
        pressed = justPressed = justReleased = pressedRight = justPressedRight = justReleasedRight = false;
        __cancelled = true;
    }

    public function new() {}

    public function set(pressed:Bool, justPressed:Bool, justReleased:Bool, pressedRight:Bool, justPressedRight:Bool, justReleasedRight:Bool) {
        this.pressed = pressed;
        this.justPressed = justPressed;
        this.justReleased = justReleased;
        this.pressedRight = pressedRight;
        this.justPressedRight = justPressedRight;
        this.justReleasedRight = justReleasedRight;
        this.screenPos = FlxG.mouse.getScreenPosition(FlxG.camera);
        this.__cancelled = false;
    }

    public function overlaps(spr:FlxObject, ?camera:FlxCamera) {
        return overlapsRect(spr, new FlxRect(spr.x, spr.y, spr.width, spr.height), camera);
        // return FlxG.mouse.overlaps(spr, camera);
    }

    public function overlapsRect(spr:FlxBasic, rect:FlxRect, ?camera:FlxCamera) {
        if (__cancelled) return false;
        if (camera == null) camera = FlxG.camera;
        if (spr is FlxObject && camera != null) {
            var obj = cast(spr, FlxObject);
            rect.x -= camera.scroll.x * obj.scrollFactor.x;
            rect.y -= camera.scroll.y * obj.scrollFactor.y;
        }
        var pos = FlxG.mouse.getScreenPosition(camera);
        
        return ((pos.x > rect.x) && (pos.x < rect.x + rect.width)) && ((pos.y > rect.y) && (pos.y < rect.y + rect.height));
    }
}

interface IDesktopFocusableObject {
    public function onFocus():Void;
    public function onFocusLost():Void;
}

// useless, only here for 
interface IDesktopInputObject {

}