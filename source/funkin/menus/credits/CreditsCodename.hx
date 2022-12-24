package funkin.menus.credits;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import funkin.github.GitHub;
import funkin.menus.MainMenuState;

class CreditsCodename extends MusicBeatState {
    public var contributorsSprites:Array<FlxSprite> = [];
    public var contributorsAvatars:Array<FlxGraphic> = [];
    public var avatarLoadListId:Int = 0;
    public override function create() {
        super.create();

		var bg:FlxSprite = new FlxSprite(-80).loadAnimatedGraphic(Paths.image('menus/menuBGBlue'));
        bg.scrollFactor.set();
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

        var contributors = GitHub.getContributors("YoshiCrafter29", "CodenameEngine", function(e) {
            trace(e);
        });
        for(k=>c in contributors) {
            var spr = new FlxSprite(0, k * 50);
            spr.antialiasing = true;
            spr.setUnstretchedGraphicSize(50, 50, false);
            contributorsSprites.push(spr);
            add(spr);
        }

        Main.execAsync(function() {
            for(k=>c in contributors) {
                var bytes = GitHub.__requestBytesOnGitHubServers('${c.avatar_url}&size=64');
                var bmap = BitmapData.fromBytes(bytes);
                contributorsAvatars.push(FlxG.bitmap.add(bmap, false, 'GITHUB-USER:${c.login}'));
                if (destroyed) return;
            }
        });
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (controls.BACK) {
            CoolUtil.playMenuSFX(2);
            FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
            FlxG.switchState(new MainMenuState());
        }
        if (avatarLoadListId < contributorsAvatars.length) {
            for(i in avatarLoadListId...contributorsAvatars.length) {
                var v = contributorsSprites[i];
                v.loadGraphic(contributorsAvatars[i]);
                v.setUnstretchedGraphicSize(50, 50, false);
            }
            avatarLoadListId = contributorsAvatars.length;
        }
    }

    public override function destroy() {
        super.destroy();
    }
}