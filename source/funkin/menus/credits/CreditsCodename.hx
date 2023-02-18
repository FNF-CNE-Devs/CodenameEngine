package funkin.menus.credits;

import funkin.shaders.CustomShader;
import flixel.math.FlxMath;
import funkin.options.type.TextOption;
import funkin.options.OptionsScreen;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import funkin.github.GitHub;
import funkin.github.GitHubContributor;
import funkin.menus.MainMenuState;

class CreditsCodename extends OptionsScreen {
    public var contributorsSprites:Array<FlxSprite> = [];
    public var contributorsAvatars:Array<FlxGraphic> = [];
    public var avatarLoadListId:Int = 0;
    public var contributors:Array<GitHubContributor>;

    public override function create() {

		var bg:FlxSprite = new FlxSprite(-80).loadAnimatedGraphic(Paths.image('menus/menuBGBlue'));
        bg.scrollFactor.set();
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

        contributors = GitHub.getContributors("YoshiCrafter29", "CodenameEngine", function(e) {
            trace(e);
        });

        var totalContributions = 0;
        
        for(c in contributors)
            totalContributions += c.contributions;

        options = [for(c in contributors) new TextOption(
            c.login,
            'Total Contributions: ${c.contributions} / ${totalContributions} (${FlxMath.roundDecimal(c.contributions / totalContributions * 100, 2)}%) - Select to open GitHub account',
            function() {
                // open the link
                CoolUtil.openURL(c.html_url);
            })];


        super.create();
    }

    public override function createAdditional() {
        for(k=>c in contributors) {
            var spr = new FlxSprite(0, (OptionsScreen.optionHeight * (k+0.5)) - 48);
            spr.antialiasing = true;
            spr.setUnstretchedGraphicSize(96, 96, false);
            spr.updateHitbox();
            spr.shader = new CustomShader('circleProfilePicture');
            contributorsSprites.push(spr);
            add(spr);
        }

        // asynchronous pfp loading
        Main.execAsync(function() {
            for(k=>c in contributors) {
                var bytes = GitHub.__requestBytesOnGitHubServers('${c.avatar_url}&size=96');
                var bmap = BitmapData.fromBytes(bytes);
                contributorsAvatars.push(FlxG.bitmap.add(bmap, false, 'GITHUB-USER:${c.login}'));
                if (destroyed) return;
            }
        });
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (avatarLoadListId < contributorsAvatars.length) {
            for(i in avatarLoadListId...contributorsAvatars.length) {
                var v = contributorsSprites[i];
                v.loadGraphic(contributorsAvatars[i]);
                v.setUnstretchedGraphicSize(96, 96, false);
                v.updateHitbox();
            }
            avatarLoadListId = contributorsAvatars.length;
        }

        for(k=>spr in contributorsSprites) {
            var alpha = options[k];
            spr.x = alpha.x - 10;
        }
    }

    public override function destroy() {
        super.destroy();
    }
}