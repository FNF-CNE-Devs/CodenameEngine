package funkin.game;

import flixel.FlxSprite;
import openfl.utils.Assets;
import haxe.xml.Access;
import flixel.FlxBasic;
import funkin.interfaces.IBeatReceiver;
import funkin.scripting.Script;
import haxe.io.Path;

class Stage extends FlxBasic implements IBeatReceiver {
    public var stageXML:Access;
    public var stagePath:String;
    public var stageSprites:Map<String, FlxSprite> = [];
    public var stageScript:Script;
    
    public function getSprite(name:String) {
        return stageSprites[name];
    }

    public function new(stage:String) {
        super();
        if (PlayState.instance == null) return;
        stagePath = Paths.xml('stages/$stage');
        try {
            if (Assets.exists(stagePath)) stageXML = new Access(Xml.parse(Assets.getText(stagePath)).firstElement());
        } catch(e) {
            // TODO: handler
            trace(e.details());
        }
        if (stageXML != null) {

            var spritesParentFolder = "";
            if (stageXML.has.zoom) {
                var parsed:Null<Float> = Std.parseFloat(stageXML.att.zoom);
                if (parsed != null) PlayState.instance.defaultCamZoom = parsed;
            }
            if (stageXML.has.folder) {
                spritesParentFolder = stageXML.att.folder;
                if (spritesParentFolder.charAt(spritesParentFolder.length-1) != "/") spritesParentFolder = spritesParentFolder + "/";
            }
            if (stageXML.has.name) PlayState.instance.curStage = stageXML.att.name;
        
            for(node in stageXML.elements) {
                switch(node.name) {
                    case "sprite" | "spr" | "sparrow":
                        var spr = new FlxSprite();
                        spr.antialiasing = true;
                        if (!node.has.sprite || !node.has.name || !node.has.x || !node.has.y) continue;
    
                        if (Assets.exists(Paths.file('images/$spritesParentFolder${node.att.sprite}', TEXT))) {
                            spr.frames = Paths.getSparrowAtlas('$spritesParentFolder${node.att.sprite}');
                        } else {
                            spr.loadGraphic(Paths.image('$spritesParentFolder${node.att.sprite}'));
                        }
                        var x:Null<Float> = Std.parseFloat(node.att.x);
                        var y:Null<Float> = Std.parseFloat(node.att.y);
                        if (x != null) spr.x = x;
                        if (y != null) spr.y = y;
                        if (node.has.scroll) {
                            var scroll:Null<Float> = Std.parseFloat(node.att.scroll);
                            if (scroll != null) spr.scrollFactor.set(scroll, scroll);
                        }
                        if (node.has.scale) {
                            var scale:Null<Float> = Std.parseFloat(node.att.scale);
                            if (scale != null) spr.scale.set(scale, scale);
                        }
                        if (node.has.updateHitbox && node.att.updateHitbox == "true") spr.updateHitbox();
                        
                        for(anim in node.nodes.anim) CoolUtil.addXMLAnimation(spr, anim);
    
                        stageSprites.set(node.att.name, spr);
                        PlayState.instance.add(spr);
                    case "boyfriend" | "bf":
                        if (node.has.x) {
                            var x:Null<Float> = Std.parseFloat(node.att.x);
                            if (x != null) PlayState.instance.boyfriend.x = x;
                        }
                        if (node.has.y) {
                            var y:Null<Float> = Std.parseFloat(node.att.y);
                            if (y != null) PlayState.instance.boyfriend.y = y;
                        }
                        PlayState.instance.add(PlayState.instance.boyfriend);
                    case "girlfriend" | "gf":
                        if (node.has.x) {
                            var x:Null<Float> = Std.parseFloat(node.att.x);
                            if (x != null) PlayState.instance.gf.x = x;
                        }
                        if (node.has.y) {
                            var y:Null<Float> = Std.parseFloat(node.att.y);
                            if (y != null) PlayState.instance.gf.y = y;
                        }
                        PlayState.instance.add(PlayState.instance.gf);
                    case "dad" | "opponent":
                        if (node.has.x) {
                            var x:Null<Float> = Std.parseFloat(node.att.x);
                            if (x != null) PlayState.instance.dad.x = x;
                        }
                        if (node.has.y) {
                            var y:Null<Float> = Std.parseFloat(node.att.y);
                            if (y != null) PlayState.instance.dad.y = y;
                        }
                        PlayState.instance.add(PlayState.instance.dad);
                }
            }
        }
        stageScript = Script.create(Paths.script('data/stages/$stage'));
        for(k=>e in stageSprites) {
            stageScript.set(k, e);
        }
        PlayState.instance.scripts.add(stageScript);
    }

    public function beatHit(curBeat:Int) {}

    public function stepHit(curStep:Int) {}
}