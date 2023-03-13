package funkin.game;

import funkin.options.Options;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
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
    public var state:FlxState;
    public var characterPoses:Map<String, StageCharPos> = [];

    public function getSprite(name:String) {
        return stageSprites[name];
    }

    public function new(stage:String, ?state:FlxState) {
        super();

        if (state == null) state = PlayState.instance;
        if (state == null) state = FlxG.state;
        this.state = state;

        stagePath = Paths.xml('stages/$stage');
        try {
            if (Assets.exists(stagePath)) stageXML = new Access(Xml.parse(Assets.getText(stagePath)).firstElement());
        } catch(e) {
            Logs.trace('Couldn\'t load stage "$stage": ${e.message}', ERROR);
        }
        if (stageXML != null) {

            var spritesParentFolder = "";
            if (PlayState.instance != null) {
                if (stageXML.has.zoom) {
                    var parsed:Null<Float> = Std.parseFloat(stageXML.att.zoom);
                    if (parsed != null && PlayState.instance != null) PlayState.instance.defaultCamZoom = parsed;
                }
                PlayState.instance.curStage = stageXML.has.name ? stageXML.att.name : stage;
            }
            if (stageXML.has.folder) {
                spritesParentFolder = stageXML.att.folder;
                if (spritesParentFolder.charAt(spritesParentFolder.length-1) != "/") spritesParentFolder = spritesParentFolder + "/";
            }

            var elems = [];
            for(node in stageXML.elements) {
                if (node.name == "high-memory" && !Options.lowMemoryMode)
                    for(e in node.elements)
                        elems.push(e);
                else
                    elems.push(node);
            }

            for(node in elems) {
                var sprite:Dynamic = switch(node.name) {
                    case "sprite" | "spr" | "sparrow":
                        if (!node.has.sprite || !node.has.name || !node.has.x || !node.has.y) continue;

                        var spr = XMLUtil.createSpriteFromXML(node, spritesParentFolder, BEAT);

                        if (!node.has.zoomfactor && PlayState.instance != null)
                            spr.initialZoom = PlayState.instance.defaultCamZoom;

                        stageSprites.set(spr.name, spr);
                        state.add(spr);
                        spr;
                    case "box":
                        if ( !node.has.name || !node.has.width || !node.has.height) continue;

                        var spr = new FlxSprite(
                            (node.has.x) ? Std.parseFloat(node.att.x) : 0,
                            (node.has.y) ? Std.parseFloat(node.att.y) : 0
                        ).makeGraphic(
                            Std.parseInt(node.att.width),
                            Std.parseInt(node.att.height),
                            (node.has.color) ? CoolUtil.getColorFromDynamic(node.att.color) : 0xFFFFFFFF
                        );

                        stageSprites.set(node.getAtt("name"), spr);
                        state.add(spr);
                        spr;
                    case "boyfriend" | "bf":
                        addCharPos("boyfriend", node, {
                            x: 770,
                            y: 100
                        });
                        null;
                    case "girlfriend" | "gf":
                        addCharPos("girlfriend", node, {
                            x: 400,
                            y: 130
                        });
                        null;
                    case "dad" | "opponent":
                        addCharPos("dad", node, {
                            x: 100,
                            y: 100
                        });
                        null;
                    case "character":
                        if (!node.has.name) continue;
                        addCharPos(node.att.name, node);
                        null;
                    case "ratings" | "combo":
                        if (PlayState.instance == null) continue;
                        PlayState.instance.comboGroup.setPosition(
                            Std.parseFloat(node.getAtt("x")).getDefault(PlayState.instance.comboGroup.x),
                            Std.parseFloat(node.getAtt("y")).getDefault(PlayState.instance.comboGroup.y)
                        );
                        PlayState.instance.add(PlayState.instance.comboGroup);
                        PlayState.instance.comboGroup;
                    default: null;
                }
                if (sprite != null) {
                    for(e in node.nodes.property)
                        XMLUtil.applyXMLProperty(sprite, e);
                }
            }
        }

        if (characterPoses["girlfriend"] == null)
            addCharPos("girlfriend", null, {
                x: 400,
                y: 130
            });

        if (characterPoses["dad"] == null)
            addCharPos("dad", null, {
                x: 100,
                y: 100
            });

        if (characterPoses["boyfriend"] == null)
            addCharPos("boyfriend", null, {
                x: 770,
                y: 100
            });

        if (PlayState.instance == null) return;
        stageScript = Script.create(Paths.script('data/stages/$stage'));
        for(k=>e in stageSprites) {
            stageScript.set(k, e);
        }
        PlayState.instance.scripts.add(stageScript);
    }

    public function addCharPos(name:String, node:Access, ?nonXMLInfo:StageCharPosInfo) {
        var dummyBasic:FlxBasic = new FlxBasic();
        dummyBasic.active = false;
        state.add(dummyBasic);

        characterPoses[name] = {
            node: node,
            nonXMLInfo: nonXMLInfo,
            dummy: dummyBasic
        };

    }

    public function applyCharStuff(char:Character, posName:String) {
        if (characterPoses[posName] == null)
            state.add(char);
        else {
            var charPos = characterPoses[posName];
            if (charPos.nonXMLInfo != null)
                char.setPosition(charPos.nonXMLInfo.x, charPos.nonXMLInfo.y);
            if (charPos.node != null)
                doCharNodeShit(char, charPos.node);
            state.insert(state.members.indexOf(charPos.dummy), char);
        }
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
        if (node.has.scroll) {
            var scroll:Null<Float> = Std.parseFloat(node.att.scroll);
            if (scroll != null) char.scrollFactor.set(scroll, scroll);
        }
    }

    public function beatHit(curBeat:Int) {}

    public function stepHit(curStep:Int) {}

	public function measureHit(curMeasure:Int) {}
}

typedef StageCharPos = {
    var node:Access;
    var dummy:FlxBasic;
    var ?nonXMLInfo:StageCharPosInfo;
}

typedef StageCharPosInfo = {
    var x:Float;
    var y:Float;
}