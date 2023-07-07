package funkin.menus.credits;

class CreditsCodename extends funkin.options.OptionsScreen {
	public override function new()
	{
		super("Codename Engine", "All the contributors of the engine! - Press RESET to update the list (One reset per 2 minutes).");
		checkUpdate();
		displayList();
	}

	public override function update(elapsed:Float) {
		if (funkin.options.PlayerSettings.solo.controls.RESET && checkUpdate()) displayList();
		super.update(elapsed);
	}

	public function checkUpdate():Bool {
		var curTime:Float = Date.now().getTime();
		if (Options.lastUpdated == null) Options.lastUpdated = curTime;  // First time???  - Nex_isDumb
		else if (curTime < Options.lastUpdated + 120000) return false;  // Fuck you Github rate limits  - Nex_isDumb
		Options.lastUpdated = curTime;

		var error:Bool = false;
		//Main.execAsync(function() {
		var idk = funkin.backend.system.github.GitHub.getContributors("FNF-CNE-Devs", "CodenameEngine", function(e) {
			error = true;
			trace(Std.string(e));
		});
		//});
		if(error) return false;
		
		Options.contributors = idk;
		trace('List Updated!');
		return true;
	}

	public function displayList() {
		//if (curSelected > Options.contributors.length - 1) changeSelection(-(curSelected - (Options.contributors.length - 1)));
		if (curSelected > Options.contributors.length - 1) curSelected = Options.contributors.length - 1;
		changeSelection(0, true);
		
		while (members.length > 0) {
			members[0].destroy();
			remove(members[0], true);
		}

		var totalContributions = 0;
		for(c in Options.contributors) totalContributions += c.contributions;
		for(c in Options.contributors) {
			add(new funkin.options.type.TextOption(
				c.login,
				'Total Contributions: ${c.contributions} / ${totalContributions} (${FlxMath.roundDecimal(c.contributions / totalContributions * 100, 2)}%) - Select to open GitHub account',
				function() CoolUtil.openURL(c.html_url)
			));
		}
	}
}