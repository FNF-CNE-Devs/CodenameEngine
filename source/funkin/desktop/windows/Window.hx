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
    public var windowInactiveFrame:FlxUI9SliceSprite;
    public var captionButtons:FlxTypedSpriteGroup<WindowCaptionButton>;

    public var windowWidth:Int = 0;
    public var windowHeight:Int = 0;

    public var windowCaptionCamera:FlxCamera;
    public var windowCameras:Array<WindowCam> = [];

    private var __captionTweens:Array<FlxTween> = [];
    private var __closing:Bool = false;

    public var content:WindowContent;

    public var caption:FlxUIText;
    public var icon:FlxSprite;
    public var dragHitbox:WindowDragHitbox;

    public var moveable:Bool = true;
    public var resizeable:Bool = true;

    public var focused(get, null):Bool;

    private function get_focused() {
        return DesktopMain.instance.windows.members.last() == this;
    }

    public function loadIcon(path:String) {
        icon.loadGraphic(path);
        icon.setUnstretchedGraphicSize(16, 16, false);
    }
    public function new(content:WindowContent) {
        super();
        windowFrame = new FlxUI9SliceSprite(0, 0,
            Paths.image(DesktopMain.theme.captionActive.sprite),
            new Rectangle(10, 10), [
                Std.int(DesktopMain.theme.captionActive.left),
                Std.int(DesktopMain.theme.captionActive.top),
                Std.int(DesktopMain.theme.captionActive.right),
                Std.int(DesktopMain.theme.captionActive.bottom)
            ]);
        windowInactiveFrame = new FlxUI9SliceSprite(0, 0,
            Paths.image(DesktopMain.theme.captionInactive.sprite),
            new Rectangle(10, 10), [
                Std.int(DesktopMain.theme.captionInactive.left),
                Std.int(DesktopMain.theme.captionInactive.top),
                Std.int(DesktopMain.theme.captionInactive.right),
                Std.int(DesktopMain.theme.captionInactive.bottom)
            ]);
        add(windowFrame);
        add(windowInactiveFrame);

        caption = new FlxUIText(24, 4, 0, content.title);
        captionButtons = new FlxTypedSpriteGroup<WindowCaptionButton>();
        for(i in 0...4) {
            var btn = new WindowCaptionButton(this, i);
            btn.x = (i+1) * -(DesktopMain.theme.captionButtons.size.x + DesktopMain.theme.captionButtons.margin.x);
            captionButtons.add(btn);
        }
        add(caption);

        dragHitbox = new WindowDragHitbox(DesktopMain.theme.captionActive.left, DesktopMain.theme.captionActive.left, DesktopMain.theme.captionActive.left, DesktopMain.theme.captionActive.top);
        dragHitbox.parent = this;
        add(dragHitbox);

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
        dragHitbox.cameras = [windowCaptionCamera];
        
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
        @:privateAccess content.__noParentUpdate = true;
        content.winX = windowCaptionCamera.x = x;
        content.winY = windowCaptionCamera.y = y;
        @:privateAccess content.__noParentUpdate = false;
        for(e in windowCameras) {
            e.camera.x = x + Std.int(DesktopMain.theme.captionActive.left);
            e.camera.y = y + Std.int(DesktopMain.theme.captionActive.top);
        }
    }

    public override function update(elapsed:Float) {
        if (__closing) {
            DesktopMain.instance.windows.remove(this, true);
            destroy();
            return;
        }
        windowInactiveFrame.visible = !(windowFrame.visible = focused);
        var i = members.length;
        
        var shouldCancel = DesktopMain.instance.mouseInput.overlapsRect(this, new Rectangle(0, 0, windowCaptionCamera.width, windowCaptionCamera.height), windowCaptionCamera);

        if (shouldCancel && DesktopMain.instance.mouseInput.justPressed)
            DesktopMain.instance.focusWindow(this);

        // updates them backwards!!
        while(i > 0) {
            i--;
            var spr = members[i];
            if (spr == null || !spr.exists) continue;
            spr.update(elapsed);
        }

        if (shouldCancel) DesktopMain.instance.mouseInput.cancel();
    }

    public function close() {
        __closing = true;
    }

    public function updateWindowFrame() {
        for(frame in [windowInactiveFrame, windowFrame])
            frame.resize(windowWidth + Std.int(DesktopMain.theme.captionActive.left * 2), windowHeight + Std.int(DesktopMain.theme.captionActive.top) + Std.int(DesktopMain.theme.captionActive.left));
        windowCaptionCamera.setSize(windowWidth + Std.int(DesktopMain.theme.captionActive.left * 2), windowHeight + Std.int(DesktopMain.theme.captionActive.top) + Std.int(DesktopMain.theme.captionActive.left));
        captionButtons.setPosition(windowWidth + Std.int((DesktopMain.theme.captionActive.left * 2) - DesktopMain.theme.captionButtons.offset.x), Std.int(DesktopMain.theme.captionButtons.offset.y));
        for(e in windowCameras) {
            e.camera.setSize(windowWidth, windowHeight);
            if (e.resizeScroll) {
                e.camera.scroll.set(-Std.int(e.camera.width - e.width), -Std.int(e.camera.height - e.height));
            }
        }
    }
}