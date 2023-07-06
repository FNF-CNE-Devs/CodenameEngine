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
	public var contributors(default, set):Array<GitHubContributor> = [];

	public override function new()
	{
		super("Codename Engine", "All the contributors of the engine!");
		Main.execAsync(function() {
			contributors = GitHub.getContributors("FNF-CNE-Devs", "CodenameEngine", function(e) {
				trace(Std.string(e));
			});
		});
	}

	function set_contributors(daList:Array<GitHubContributor>):Array<GitHubContributor>
	{
		while (members.length > 0) {
			members[0].destroy();
			remove(members[0], true);
		}

		var totalContributions = 0;
		for(c in daList) totalContributions += c.contributions;
		for (c in daList) {
			add(new TextOption(
				c.login,
				'Total Contributions: ${c.contributions} / ${totalContributions} (${FlxMath.roundDecimal(c.contributions / totalContributions * 100, 2)}%) - Select to open GitHub account',
				function() CoolUtil.openURL(c.html_url)
			));
		}
		updateMenuDesc();

		return contributors = daList;
	}
}