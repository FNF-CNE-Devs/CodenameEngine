package funkin.options.type;

import openfl.display.BitmapData;
import funkin.backend.shaders.CustomShader;
import funkin.backend.system.github.GitHubContributor;
import funkin.backend.system.github.GitHub;
import flixel.util.FlxColor;

class GithubIconOption extends TextOption
{
	public var user(default, null):GitHubContributor;
	public var icon:FunniIcon = null;
	public var usePortrait(default, set) = true;

	public function set_usePortrait(value:Bool)
	{
		if (icon == null) return usePortrait = false;
		icon.shader = (value ? new CustomShader('engine/circleProfilePicture') : null);
		return usePortrait = value;
	}

	public function new(name:String, desc:String, callback:Void->Void, ?user:GitHubContributor, size:Int = 96, usePortrait:Bool = true) {
		super(name, desc, callback);
		if (user != null) {
			this.user = user;
			this.icon = new FunniIcon(user, size);
			this.usePortrait = usePortrait;
			add(icon);
		}
	}
}

class FunniIcon extends FlxSprite
{
	var loading:Bool = false;
	var user:GitHubContributor;
	var size:Int;

	public override function new(user:GitHubContributor, size:Int = 96) {
		this.user = user;
		this.size = size;
		super();
		makeGraphic(size, size, FlxColor.TRANSPARENT);
		antialiasing = true;
	}

	override function drawComplex(camera:FlxCamera):Void {  // Making the image downlaod only if the player actually sees it on the screeeeen  - Nex_isDumb
		if(!loading) {
			loading = true;
			loadFromGithub();
		}
		super.drawComplex(camera);
	}

	final mutex = new sys.thread.Mutex();
	private function loadFromGithub() {
		Main.execAsync(function() {
			trace('Downlaoding avatar: ${user.login}');
			var bytes = GitHub.__requestBytesOnGitHubServers('${user.avatar_url}&size=$size');
			var bmap = BitmapData.fromBytes(bytes);

			mutex.acquire();  // Wanna make sure here too  - Nex_isDumb
			loadGraphic(FlxG.bitmap.add(bmap, false, 'GITHUB-USER:${user.login}'));
			this.setUnstretchedGraphicSize(size, size, false);
			updateHitbox();
			x += 90 - width;
			mutex.release();
		});
	}
}