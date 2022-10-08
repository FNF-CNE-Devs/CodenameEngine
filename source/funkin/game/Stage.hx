package funkin.game;

import funkin.system.XMLUtil;
import flixel.FlxSprite;
import openfl.utils.Assets;
import haxe.xml.Access;
import flixel.FlxBasic;
import flixel.math.FlxMath;
import funkin.interfaces.IBeatReceiver;
import funkin.scripting.Script;
import haxe.io.Path;

using StringTools;

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
                var sprite:Dynamic = switch(node.name) {
                    case "sprite" | "spr" | "sparrow":
                        var spr = new StageSprite();
                        spr.antialiasing = true;

                        var addDefAnim = true;
                        if (!node.has.sprite || !node.has.name || !node.has.x || !node.has.y) continue;
    
                        if (Assets.exists(Paths.file('images/$spritesParentFolder${node.att.sprite}.xml', TEXT))) {
                            spr.frames = Paths.getSparrowAtlas('$spritesParentFolder${node.att.sprite}');
                        } else {
                            addDefAnim = false;
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

                        for(anim in node.nodes.anim) {
                            addDefAnim = false;
                            if (anim.has.name) spr.beatAnims.push(anim.att.name);
                            XMLUtil.addXMLAnimation(spr, anim);
                        }
                        if (node.has.beatAnim && node.att.beatAnim.trim() != "") spr.beatAnims = [for(e in node.att.beatAnim.split(",")) e.trim()];
                        
                        if (node.has.anim) {
                            spr.animation.play(node.att.anim);   
                        } else if (addDefAnim) {
                            spr.animation.addByPrefix("anim", "", 24, true);
                            spr.animation.play("anim");
                        }
    
                        stageSprites.set(node.att.name, spr);
                        PlayState.instance.add(spr);
                        spr;
                    case "boyfriend" | "bf":
                        doCharNodeShit(PlayState.instance.boyfriend, node);
                        PlayState.instance.add(PlayState.instance.boyfriend);
                        PlayState.instance.boyfriend;
                    case "girlfriend" | "gf":
                        doCharNodeShit(PlayState.instance.gf, node);
                        PlayState.instance.add(PlayState.instance.gf);
                        PlayState.instance.gf;
                    case "dad" | "opponent":
                        doCharNodeShit(PlayState.instance.dad, node);
                        PlayState.instance.add(PlayState.instance.dad);
                        PlayState.instance.dad;
                    default: null;
                }
                if (sprite != null) {
                    for(e in node.nodes.property) {
                        trace(XMLUtil.applyXMLProperty(sprite, e));
                    }
                }
            }
        }
        stageScript = Script.create(Paths.script('data/stages/$stage'));
        for(k=>e in stageSprites) {
            stageScript.set(k, e);
        }
        PlayState.instance.scripts.add(stageScript);
    }
    

    private static function doCharNodeShit(char:Character, node:Access) {
        if (node.has.x) {
            var x:Null<Float> = Std.parseFloat(node.att.x);
            if (x != null) char.x = x;
        }
        if (node.has.y) {
            var y:Null<Float> = Std.parseFloat(node.att.y);
            if (y != null) char.y = y;
        }
        if (node.has.camxoffset) {
            var x:Null<Float> = Std.parseFloat(node.att.camxoffset);
            if (x != null) char.cameraOffset.x += x;
        }
        if (node.has.camyoffset) {
            var y:Null<Float> = Std.parseFloat(node.att.camyoffset);
            if (y != null) char.cameraOffset.y += y;
        }
    }

    public function beatHit(curBeat:Int) {}

    public function stepHit(curStep:Int) {}
}

class StageSprite extends FlxSprite implements IBeatReceiver {
    public var beatAnims:Array<String> = [];

    public override function update(elapsed:Float) {
        super.update(elapsed);
    }

    public function beatHit(curBeat:Int) {
        if (beatAnims.length > 0)
            animation.play(beatAnims[FlxMath.wrap(curBeat, 0, beatAnims.length-1)]);
        
    }
    public function stepHit(curBeat:Int) {}
}