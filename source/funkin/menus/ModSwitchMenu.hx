package funkin.menus;

#if MOD_SUPPORT
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.ui.Alphabet;
import haxe.io.Path;
import funkin.mods.ModsFolder;
import sys.FileSystem;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxG;

class ModSwitchMenu extends MusicBeatSubstate {
    var mods:Array<String> = [];
    var alphabets:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;

    public override function create() {
        super.create();
        
        var bg = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFF000000);
        bg.scale.set(FlxG.width, FlxG.height);
        bg.updateHitbox();
        bg.scrollFactor.set();
        add(bg);

        bg.alpha = 0;
        FlxTween.tween(bg, {alpha: 0.5}, 0.25, {ease: FlxEase.cubeOut});

        for(modFolder in FileSystem.readDirectory(ModsFolder.modsPath)) {
            if (FileSystem.isDirectory('${ModsFolder.modsPath}${modFolder}')) {
                mods.push(modFolder);
            } else {
                var ext = Path.extension(modFolder).toLowerCase();
                switch(ext) {
                    case 'zip':
                        // is a zip mod!!
                        mods.push(Path.withoutExtension(modFolder));
                }
            }
        }

        alphabets = new FlxTypedGroup<Alphabet>();
        for(mod in mods) {
            var a = new Alphabet(0, 0, mod, true);
            a.isMenuItem = true;
            a.scrollFactor.set();
            alphabets.add(a);
        }
        add(alphabets);
        changeSelection(0, true);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        changeSelection((controls.DOWN_P ? 1 : 0) + (controls.UP_P ? -1 : 0));

        if (controls.ACCEPT) {
            ModsFolder.switchMod(mods[curSelected]);
            close();
        }
    }

    public function changeSelection(change:Int, force:Bool = false) {
        if (change == 0 && !force) return;

        curSelected = FlxMath.wrap(curSelected + change, 0, alphabets.length-1);

        CoolUtil.playMenuSFX(0, 0.7);

        for(k=>alphabet in alphabets.members) {
            alphabet.alpha = 0.6;
            alphabet.targetY = k - curSelected;
        }
        alphabets.members[curSelected].alpha = 1;
    }
}
#end