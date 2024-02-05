package funkin.menus.credits;

import funkin.backend.system.github.GitHub;
import funkin.options.type.GithubIconOption;
import flixel.text.FlxText;

using StringTools;

class CreditsCodename extends funkin.options.OptionsScreen {
	public var error:Bool = false;
	public var author:String = "FNF-CNE-Devs";

	public override function new()
	{
		super("Codename Engine", "All the contributors of the engine! - Press RESET to update the list (One reset per 2 minutes).");
		checkUpdate();
		displayList();
	}

	public override function update(elapsed:Float) {
		if (funkin.options.PlayerSettings.solo.controls.RESET && checkUpdate()) {
			displayList();
			updateMenuDesc();
		}
		super.update(elapsed);
	}

	public override function updateMenuDesc(?txt:String) {
		super.updateMenuDesc(txt);
		parent.treeParent.pathDesc.applyMarkup(parent.treeParent.pathDesc.text, [new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF9C35D5), "*")]);
	}

	public function checkUpdate():Bool {
		var curTime:Float = Date.now().getTime();
		if(Options.lastUpdated != null && curTime < Options.lastUpdated + 120000) return false;  // Fuck you Github rate limits
		Options.lastUpdated = curTime;

		error = false;
		//Main.execAsync(function() {
		var idk = GitHub.getContributors(author, "CodenameEngine", function(e) {
			error = true;
			var errMsg:String = 'Error while trying to download contributors list:\n${CoolUtil.removeIP(e.message)}';
			Logs.traceColored([Logs.logText(errMsg.replace('\n', ' '), RED)], ERROR);
			funkin.backend.utils.NativeAPI.showMessageBox("Codename Engine Warning", errMsg, MSG_WARNING);
		});
		//});
		if(error) return false;
		Options.contributors = idk;
		trace('List Updated!');

		var errorOnMain:Bool = false;
		var idk2 = GitHub.getOrganizationMembers(author, function(e) {
			errorOnMain = true;
			var errMsg:String = 'Error while trying to download $author members list:\n${CoolUtil.removeIP(e.message)}';
			Logs.traceColored([Logs.logText(errMsg.replace('\n', ' '), RED)], ERROR);
			funkin.backend.utils.NativeAPI.showMessageBox("Codename Engine Warning", errMsg, MSG_WARNING);
		});
		if(!errorOnMain) Options.mainDevs = [for(m in idk2) m.id];

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
			var desc:String = 'Total Contributions: ${c.contributions} / ${totalContributions} (${FlxMath.roundDecimal(c.contributions / totalContributions * 100, 2)}%) - Select to open GitHub account';
			if(Options.mainDevs.contains(c.id)) desc += " *- Public member of the main Devs!*";
			var opt:GithubIconOption = new GithubIconOption(c, desc);
			add(opt);
		}
	}
}