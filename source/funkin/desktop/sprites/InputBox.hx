package funkin.desktop.sprites;

import flixel.math.FlxMath;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import flixel.FlxG;
import lime.app.Application;

class InputBox extends Button {
    public var index:Int = 0;

    public function new(x:Float, y:Float, w:Float, t:String, onChange:Void->Void) {
        super(x, y, t, function() {
            setIndex(label.text.length);
        });
        this.resize(w, height);
        this.label.alignment = LEFT;
        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        Application.current.window.onTextInput.add(onTextInput);
    }

    private function onKeyDown(event:KeyboardEvent) {
        if (!this.hasFocus()) return;
        switch(event.keyCode) {
            case Keyboard.CONTROL | Keyboard.SHIFT:
                // nothing
            case Keyboard.ESCAPE:
                this.loseFocus();
            case Keyboard.LEFT:
                changeIndex(-1);
            case Keyboard.RIGHT:
                changeIndex(1);
            case Keyboard.ENTER | Keyboard.NUMPAD_ENTER:
                onTextInput("\n");
        }
    }

    private function onTextInput(input:String) {
        if (!this.hasFocus()) return;

        
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