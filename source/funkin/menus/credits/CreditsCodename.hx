package funkin.menus.credits;

import flixel.FlxG;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import funkin.github.GitHub;
import funkin.menus.MainMenuState;

class CreditsCodename extends MusicBeatState {
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
            var bmap = BitmapData.fromBytes(GitHub.__requestBytesOnGitHubServers('${c.avatar_url}&size=64'));

            var spr = new FlxSprite(0, k * 50);
            spr.antialiasing = true;
            spr.loadGraphic(FlxG.bitmap.add(bmap, false, 'GITHUB-USER:${c.login}'));
            spr.setUnstretchedGraphicSize(50, 50, false);
            add(spr);
        }
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (controls.BACK) {
            CoolUtil.playMenuSFX(2);
            FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
            FlxG.switchState(new MainMenuState());
        }
    }
}