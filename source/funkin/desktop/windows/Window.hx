package funkin.desktop.windows;

import flixel.math.FlxRect;
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
import funkin.desktop.sprites.*;
import funkin.desktop.editors.MessageBox.MessageBoxIcon;
import funkin.desktop.editors.MessageBox;


typedef WindowCam = {
    var camera:FlxCamera;
    var resizeScroll:Bool;
    var width:Int;
    var height:Int;
}
class Window extends FlxTypedGroup<FlxBasic> {
    public var windowFrame:SpliceSprite;
    public var windowInactiveFrame:SpliceSprite;
    public var captionButtons:FlxTypedSpriteGroup<WindowCaptionButton>;

    public var windowWidth:Int = 0;
    public var windowHeight:Int = 0;

    public var windowCaptionCamera:FlxCamera;
    public var windowCameras:Array<WindowCam> = [];

    private var __captionTweens:Array<FlxTween> = [];
    private var __closing:Bool = false;

    public var content:WindowContent;

    public var caption:WindowText;
    public var icon:FlxSprite;
    public var dragHitbox:WindowDragHitbox;

    public var moveable:Bool = true;
    public var resizeable:Bool = true;
    public var canClose:Bool = true;
    public var canMinimize:Bool = true;
    public var canHelp:Bool = false;

    public var maximized:Bool = false;

    public var focused(get, null):Bool;

    public var curDialog:Window = null;

    public function openDialog(window:Window) {
        curDialog = window;
        if (focused) DesktopMain.instance.focusWindow(curDialog);
    }
    private function get_focused() {
        return DesktopMain.instance.windows.members.last() == this;
    }

    public function showMessage(caption:String, message:String, icon:MessageBoxIcon) {
        var win = DesktopMain.instance.openWindow(new MessageBox(caption, message, icon));
        curDialog = win;
        win.move(
            windowCaptionCamera.x + ((windowCaptionCamera.width - win.windowCaptionCamera.width) / 2),
            windowCaptionCamera.y + ((windowCaptionCamera.height - win.windowCaptionCamera.height) / 2));
    }

    public function loadIcon(path:String) {
        icon.loadGraphic(path);
        icon.setUnstretchedGraphicSize(16, 16, false);
    }
    public function new(content:WindowContent) {
        super();
        windowFrame = new SpliceSprite(Paths.image(DesktopMain.theme.captionActive.sprite), 0, 0, 10, 10,
            Std.int(DesktopMain.theme.captionActive.left),
            Std.int(DesktopMain.theme.captionActive.top),
            Std.int(DesktopMain.theme.captionActive.right),
            Std.int(DesktopMain.theme.captionActive.bottom));
        windowInactiveFrame = new SpliceSprite(Paths.image(DesktopMain.theme.captionInactive.sprite), 0, 0, 10, 10,
            Std.int(DesktopMain.theme.captionInactive.left),
            Std.int(DesktopMain.theme.captionInactive.top),
            Std.int(DesktopMain.theme.captionInactive.right),
            Std.int(DesktopMain.theme.captionInactive.bottom));
        add(windowFrame);
        add(windowInactiveFrame);

        caption = new WindowText(24, 4, 0, content.title);
        caption.applyFontSettings(DesktopMain.theme.captionActive);
        caption.borderSize = 1.25;
        caption.borderStyle = OUTLINE;
        caption.borderColor = 0x63000000;

        captionButtons = new FlxTypedSpriteGroup<WindowCaptionButton>();
        for(i in 0...4) {
            var btn = new WindowCaptionButton(this, i);
            btn.x = (i+1) * -(DesktopMain.theme.captionButtons.size.x + DesktopMain.theme.captionButtons.margin.x);
            captionButtons.add(btn);
        }

        caption.y = (DesktopMain.theme.captionActive.top - caption.height) / 2;
        add(caption);

        dragHitbox = new WindowDragHitbox(DesktopMain.theme.captionActive.left, DesktopMain.theme.captionActive.left, DesktopMain.theme.captionActive.left, DesktopMain.theme.captionActive.top);
        dragHitbox.parent = this;
        add(dragHitbox);

        icon = new FlxSprite(4, (DesktopMain.theme.captionActive.top - 16) / 2);
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
            content.windowCamera.bgColor = DesktopMain.theme.window.color;
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

    public function onDesktopSizeChange(width:Int, height:Int) {
        if (maximized) {
            resize(width, Std.int(height - DesktopMain.theme.captionActive.top + DesktopMain.theme.captionActive.left));
        }
        content.onDesktopSizeChange(width, height);
    }

    public function maximize() {
        if (maximized != (maximized = true)) {
            // maximizing!!
            captionButtons.members[1].animation.play("restore", true);
            move(-DesktopMain.theme.captionActive.left, -DesktopMain.theme.captionActive.left);
            resize(FlxG.width, Std.int(FlxG.height - DesktopMain.theme.captionActive.top + DesktopMain.theme.captionActive.left)); // TODO: taskbar stuff
        }
    }

    public function minimize() {

    }

    public function restore() {
        if (maximized != (maximized = false)) {
            // maximizing!!
            captionButtons.members[1].animation.play("maximize", true);
            move(100, 100);
            var w:Int = 320;
            var h:Int = 320;
            if (windowCameras[0] != null) {
                w = windowCameras[0].width;
                h = windowCameras[0].height;
            }
            resize(w, h); // TODO: taskbar stuff
        }
    }

    public function changeCaption(text:String) {
        caption.text = text;
    }

    public function popupCamera(cam:FlxCamera, popout:Bool = false, ?onFinish:FlxTween->Void) {
        if (popout) {
            __captionTweens.push(FlxTween.tween(cam.flashSprite, {scaleX: 0.85, scaleY: 0.85}, 1/5, {ease: FlxEase.quintOut}));
            __captionTweens.push(FlxTween.tween(cam, {alpha: 0}, 1/5, {ease: FlxEase.quintOut, onComplete: onFinish}));
        } else {
            cam.flashSprite.scaleX = 0.85;
            cam.flashSprite.scaleY = 0.85;
            cam.alpha = 0;
    
            __captionTweens.push(FlxTween.tween(cam.flashSprite, {scaleX: 1, scaleY: 1}, 1/3, {ease: FlxEase.cubeOut}));
            __captionTweens.push(FlxTween.tween(cam, {alpha: 1}, 1/3, {ease: FlxEase.cubeOut, onComplete: onFinish}));
        }
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
            // DesktopMain.instance.windows.remove(this, true);
            // destroy();
            return;
        }
        windowInactiveFrame.visible = !(windowFrame.visible = focused);
        var i = members.length;
        
        var shouldCancel = DesktopMain.mouseInput.overlapsRect(this, new FlxRect(0, 0, windowCaptionCamera.width, windowCaptionCamera.height), windowCaptionCamera);

        

        if (curDialog != null && curDialog.exists) {
            if (shouldCancel) {
                if (DesktopMain.mouseInput.justPressed) {
                    // TODO: sounds
                    DesktopMain.instance.focusWindow(curDialog);
                }
                DesktopMain.mouseInput.cancel();
            }
            return;
        } else if (shouldCancel && DesktopMain.mouseInput.justPressed)
            DesktopMain.instance.focusWindow(this);
        // updates them backwards!!
        while(i > 0) {
            i--;
            var spr = members[i];
            if (spr == null || !spr.exists) continue;
            spr.update(elapsed);
        }

        if (shouldCancel) DesktopMain.mouseInput.cancel();
    }

    public function close() {
        __closing = true;
        popupCamera(windowCaptionCamera, true, function(t) {
            DesktopMain.instance.windows.remove(this, true);
            destroy();
        });
        for(e in windowCameras) popupCamera(e.camera, true);
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
        content.onWindowResize(windowWidth, windowHeight);
    }
}