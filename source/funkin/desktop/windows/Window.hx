package funkin.desktop.windows;

import flixel.addons.ui.FlxUIText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;
import openfl.geom.Point;
import flixel.group.FlxSpriteGroup;
import openfl.geom.Rectangle;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;


typedef WindowCam = {
    var camera:FlxCamera;
    var resizeScroll:Bool;
    var width:Int;
    var height:Int;
}
class Window extends FlxTypedGroup<FlxBasic> {
    public var windowFrame:FlxUI9SliceSprite;
    public var captionButtons:FlxTypedSpriteGroup<WindowCaptionButton>;

    public var windowWidth:Int = 0;
    public var windowHeight:Int = 0;

    public var windowCaptionCamera:FlxCamera;
    public var windowCameras:Array<WindowCam> = [];

    private var __captionTweens:Array<FlxTween> = [];

    public var content:WindowContent;

    public var caption:FlxUIText;
    public var icon:FlxSprite;

    public var draggable:Bool = true;
    public var resizeable:Bool = true;

    public function loadIcon(path:String) {
        icon.loadGraphic(path);
        icon.setUnstretchedGraphicSize(16, 16, false);
    }
    public function new(content:WindowContent) {
        super();
        windowFrame = new FlxUI9SliceSprite(0, 0, Paths.image('desktop/windowFrame'), new Rectangle(10, 10), [3, 3, 6, 6]);
        add(windowFrame);

        caption = new FlxUIText(24, 4, 0, content.title);
        captionButtons = new FlxTypedSpriteGroup<WindowCaptionButton>();
        for(i in 0...3) {
            var btn = new WindowCaptionButton(this, i);
            btn.x = (i+1) * -18;
            captionButtons.add(btn);
        }
        add(caption);

        icon = new FlxSprite(4, 4);
        add(icon);
        loadIcon(content.icon);

        add(captionButtons);

        this.content = content;

        // scrollFactor.set(0.5, 0.5);

        windowCaptionCamera = new FlxCamera(0, 0, content.width, content.height, 1);
        windowCaptionCamera.pixelPerfectRender = true;
        windowCaptionCamera.bgColor = 0;
        FlxG.cameras.add(windowCaptionCamera, false);
        cameras = [windowCaptionCamera];
        
        for(btn in captionButtons.members)
            btn.cameras = cameras; // so that buttons detects on the right camera

        if (content.windowCamera == null) {
            content.windowCamera = new FlxCamera(Std.int(content.winX + 4), Std.int(content.winY + 23), Std.int(content.width), Std.int(content.height), 1);
            content.windowCamera.pixelPerfectRender = true;
            content.windowCamera.bgColor = -1; // walter white
        }
        content.cameras = [content.windowCamera];
        content.parent = this;
        addCamera(content.windowCamera);
        content.create();
        add(content);

        windowWidth = content.width;
        windowHeight = content.height;

        popupCamera(windowCaptionCamera);
        for(e in windowCameras) popupCamera(e.camera);

        resize(content.width, content.height);
        move(content.winX, content.winY);
    }

    public function addCamera(camera:FlxCamera, useResizeTechnique:Bool = true) {
        FlxG.cameras.add(camera, false);
        windowCameras.push({
            camera: camera,
            resizeScroll: useResizeTechnique,
            width: camera.width,
            height: camera.height
        });
    }

    public function changeCaption(text:String) {
        caption.text = text;
    }

    public function popupCamera(cam:FlxCamera) {
        cam.flashSprite.scaleX = 0.85;
        cam.flashSprite.scaleY = 0.85;
        cam.alpha = 0;

        __captionTweens.push(FlxTween.tween(cam.flashSprite, {scaleX: 1, scaleY: 1}, 1/3, {ease: FlxEase.cubeOut}));
        __captionTweens.push(FlxTween.tween(cam, {alpha: 1}, 1/3, {ease: FlxEase.cubeOut}));
    }
    public override function destroy() {
        super.destroy();
        for(e in __captionTweens) e.cancel();
        FlxG.cameras.remove(windowCaptionCamera, true);
        for(cam in windowCameras) {
            FlxG.cameras.remove(cam.camera, true);
        }
        windowCameras = null;
        windowCaptionCamera = null;
        __captionTweens = null;
    }

    public function resize(width:Int, height:Int) {
        windowWidth = width;
        windowHeight = height;
        updateWindowFrame();
    }

    public function move(x:Float, y:Float) {
        windowCaptionCamera.x = x;
        windowCaptionCamera.y = y;
        for(e in windowCameras) {
            e.camera.x = x + 4;
            e.camera.y = y + 23;
        }
    }

    public function close() {
        DesktopMain.instance.windows.remove(this, true);
        destroy();
    }

    public function updateWindowFrame() {
        windowFrame.resize(windowWidth + 4 + 4, windowHeight + 23 + 4);
        windowCaptionCamera.setSize(windowWidth + 4 + 4, windowHeight + 23 + 4);
        captionButtons.setPosition(windowWidth + 4, 4);
        for(e in windowCameras) {
            e.camera.setSize(windowWidth, windowHeight);
            if (e.resizeScroll) {
                e.camera.scroll.set(-Std.int(e.camera.width - e.width), -Std.int(e.camera.height - e.height));
            }
        }
    }
}