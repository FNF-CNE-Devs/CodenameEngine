package funkin.menus.credits;

import funkin.backend.FunkinText;
import flixel.util.FlxColor;
import funkin.backend.shaders.CustomShader;
import funkin.options.type.TextOption;
import funkin.options.OptionsScreen;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flixel.addons.transition.FlxTransitionableState;
import funkin.backend.system.github.GitHub;
import funkin.backend.system.github.GitHubContributor;
import funkin.menus.MainMenuState;

using funkin.backend.utils.BitmapUtil;

class CreditsCodename extends OptionsScreen {
	public var contributorsSprites:Array<FlxSprite> = [];
	public var contributorsAvatars:Array<FlxGraphic> = [];
	public var contributorsColors:Array<FlxColor> = [];
	public var avatarLoadListId:Int = 0;
	public var contributors:Array<GitHubContributor>;

	public var interpColor:FlxInterpolateColor;

	public var errorMessage:String = "";

	public override function create() {
		contributors = GitHub.getContributors("YoshiCrafter29", "CodenameEngine", function(e) {
			errorMessage = Std.string(e);
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
		interpColor = new FlxInterpolateColor(bg.color);
	}

	public override function changeSelection(change:Int) {
		if (contributors.length <= 0)
			return;
		super.changeSelection(change);
	}

	public override function createAdditional() {
		if (contributors.length <= 0) {
			var t = new FunkinText(0, 0, FlxG.width, 'Could not load engine contributors.\nMake sure you\'re connected to the Internet.\n\n${errorMessage}\n\nPress BACK to go back.', 40, true);
			t.alignment = CENTER;
			t.borderSize *= 1.75;
			t.screenCenter();

			var bg = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFF000000);
			bg.alpha = 0.5;
			bg.scale.set(FlxG.width - 80, t.height + 40);
			bg.updateHitbox();
			bg.screenCenter();
			add(bg);
			add(t);
			return;
		}

		for(k=>c in contributors) {
			var spr = new FlxSprite(0, (OptionsScreen.optionHeight * (k+0.5)) - 48);
			spr.antialiasing = true;
			spr.setUnstretchedGraphicSize(96, 96, false);
			spr.updateHitbox();
			spr.shader = new CustomShader('engine/circleProfilePicture');
			contributorsSprites.push(spr);
			add(spr);
		}

		// asynchronous pfp loading
		Main.execAsync(function() {
			for(k=>c in contributors) {
				var bytes = GitHub.__requestBytesOnGitHubServers('${c.avatar_url}&size=96');
				var bmap = BitmapData.fromBytes(bytes);
				var color = bmap.getMostPresentSaturatedColor();
				contributorsAvatars.push(FlxG.bitmap.add(bmap, false, 'GITHUB-USER:${c.login}'));
				contributorsColors.push(color);
				if (destroyed) return;
			}
		});
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (contributors.length <= 0) {
			if (controls.BACK)
				exit();
			return;
		}

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

		interpColor.fpsLerpTo(contributorsColors[curSelected], 0.0625);
		bg.color = interpColor.color;
	}

	public override function destroy() {
		super.destroy();
	}

	public override function exit() {
		MusicBeatState.skipTransOut = true;
		FlxG.switchState(new CreditsMain());
	}
}