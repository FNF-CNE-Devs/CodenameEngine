package funkin.desktop.sprites;

import flixel.math.FlxMath;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import flixel.FlxG;
import lime.app.Application;

class InputBox extends Button implements IDesktopInputObject {
    public var index:Int = 0;
    public static var insertMode:Bool = false;

    public var text(get, set):String;
    private inline function set_text(t:String):String
        return label.text = t;
    private inline function get_text():String
        return label.text;

    public var onChange:Void->Void;
    public var onConfirm:Void->Void;

    public function new(x:Float, y:Float, w:Float, t:String, ?onChange:Void->Void) {
        super(x, y, t, function() {
            setIndex(label.text.length);
            disabled = true;
        }, DesktopMain.theme.textbox, DesktopMain.theme.textboxHover, DesktopMain.theme.textboxPressed, DesktopMain.theme.textboxFocused);
        this.resize(w, height);
        this.label.alignment = LEFT;
        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        Application.current.window.onTextInput.add(onTextInput);
    }


    private function onKeyDown(event:KeyboardEvent) {
        if (!this.hasFocus()) return;
        switch(event.keyCode) {
            case Keyboard.ESCAPE:
                this.loseFocus();
            case Keyboard.INSERT:
                insertMode = !insertMode;
            case Keyboard.LEFT:
                changeIndex(-1);
            case Keyboard.RIGHT:
                changeIndex(1);
            case Keyboard.HOME:
                setIndex(0);
            case Keyboard.END:
                setIndex(text.length);
            case Keyboard.DELETE:
                text = text.substr(0, index) + text.substring(index + 1, text.length);
                onTextInput("");
            case Keyboard.BACKSPACE:
                text = text.substr(0, index <= 0 ? 0 : index - 1) + text.substring(index, text.length);
                changeIndex(-1);
                onTextInput("");
            case Keyboard.ENTER | Keyboard.NUMPAD_ENTER:
                if (onChange != null)
                    onChange();
                if (onConfirm != null)
                    onConfirm();
            default:
                // nothing
        }
    }

    private function onTextInput(input:String) {
        if (!this.hasFocus()) return;

        if (input.length > 0) {
            text = text.substr(0, index) + input + text.substring(index, text.length);
    
            if (!insertMode)
                index += input.length;
        }

        if (onChange != null)
            onChange();
    }

    public override function update(elapsed:Float) {
        if (DesktopMain.mouseInput.justPressed && !DesktopMain.mouseInput.overlaps(this, camera))
            this.loseFocus();
        super.update(elapsed);
    }
    
    public override function onFocusLost() {
        super.onFocusLost();
        if (disabled != (disabled = false)) {
            if (onChange != null)
                onChange();
            if (onConfirm != null)
                onConfirm();
        }
    }

    public inline function changeIndex(change:Int) {
        setIndex(Std.int(FlxMath.bound(index + change, 0, label.text.length)));
    }

    public inline function setIndex(index:Int) {
        this.index = index;
    }

    public override function destroy() {
        super.destroy();
    }
}