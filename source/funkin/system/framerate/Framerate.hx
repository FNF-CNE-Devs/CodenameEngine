package funkin.system.framerate;

import openfl.events.KeyboardEvent;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;

class Framerate extends Sprite {
    public static var instance:Framerate;
    
    public static var textFormat:TextFormat;
    public static var fpsCounter:FramerateCounter;
    public static var memoryCounter:MemoryCounter;
    #if SHOW_BUILD_ON_FPS
    public static var codenameBuildField:CodenameBuildField;
    #end

    public static var fontName:String = #if windows '${Sys.getEnv("windir")}\\Fonts\\consola.ttf' #else "_sans" #end;

    public static var debugMode:Bool = false;
    
    public var bgSprite:Sprite;

    public var categories:Array<FramerateCategory> = [];

    public function new() {
        super();
        if (instance != null) throw "Cannot create another instance";
        instance = this;
        textFormat = new TextFormat("Consolas", 12, -1);

        x = 10;
        y = 2;

        FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent) {
            switch(e.keyCode) {
                case #if web Keyboard.NUMBER_3 #else Keyboard.F3 #end: // 3 on web or F3 on windows, linux and other things that runs code
                    debugMode = !debugMode;
            }
        });

        bgSprite = new Sprite();
        bgSprite.graphics.beginFill(0xFF000000);
        bgSprite.graphics.drawRect(0, 0, 1, 1);
        bgSprite.graphics.endFill();
        bgSprite.alpha = 0;
        addChild(bgSprite);

        __addToList(fpsCounter = new FramerateCounter());
        __addToList(memoryCounter = new MemoryCounter());
        #if SHOW_BUILD_ON_FPS
        __addToList(codenameBuildField = new CodenameBuildField());
        #end
        __addCategory(new ConductorInfo());
        __addCategory(new SystemInfo());
        __addCategory(new AssetTreeInfo());
        
        #if (gl_stats && !disable_cffi && (!html5 || !canvas))
        __addCategory(new StatsInfo());
        #end
    }

    private function __addCategory(category:FramerateCategory) {
        categories.push(category);
        __addToList(category);
    }
    private var __lastAddedSprite:DisplayObject = null;
    private function __addToList(spr:DisplayObject) {
        spr.x = 0;
        spr.y = __lastAddedSprite != null ? (__lastAddedSprite.y + __lastAddedSprite.height) : 4;
        __lastAddedSprite = spr;
        addChild(spr);
    }

    
    var debugAlpha:Float = 0;
    public override function __enterFrame(t:Int) {
        super.__enterFrame(t);
        debugAlpha = CoolUtil.fpsLerp(debugAlpha, debugMode ? 1 : 0, 1);
        bgSprite.alpha = debugAlpha * 0.5;
        
        var width = Math.max(fpsCounter.width, #if SHOW_BUILD_ON_FPS Math.max(memoryCounter.width, codenameBuildField.width) #else memoryCounter.width #end) + (x*2);
        var height = #if SHOW_BUILD_ON_FPS codenameBuildField.y + codenameBuildField.height #else memoryCounter.y + memoryCounter.height #end;
        bgSprite.x = -x;
        bgSprite.scaleX = width;
        bgSprite.scaleY = height;

        var y:Float = height + 4;

        for(c in categories) {
            c.alpha = debugAlpha;
            c.x = FlxMath.lerp(-c.width, 0, debugAlpha);
            c.y = y;
            y = c.y + c.height + 4;
        }
    }
}