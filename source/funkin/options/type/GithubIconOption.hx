package funkin.options.type;

import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import funkin.backend.shaders.CustomShader;
import funkin.backend.system.github.GitHubContributor;
import funkin.backend.system.github.GitHub;
import flixel.util.FlxColor;

class GithubIconOption extends TextOption
{
	public var user(default, null):GitHubContributor = null;
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
			var key:String = 'GITHUB-USER:${user.login}';
			var bmap:Dynamic = FlxG.bitmap.get(key);

			if(bmap == null) {
				try {
					trace('Downlaoding avatar: ${user.login}');
					var bytes = GitHub.__requestBytesOnGitHubServers('${user.avatar_url}&size=$size');
					bmap = BitmapData.fromBytes(bytes);

					mutex.acquire();  // Wanna make sure here too  - Nex_isDumb
					var leGraphic:FlxGraphic = FlxG.bitmap.add(bmap, false, key);
					leGraphic.persist = true;
					updateDaFunni(leGraphic);
					mutex.release();
				} catch(e) {
					Logs.traceColored([Logs.logText('Failed to download github pfp for ${user.login}: ${CoolUtil.removeIP(e.message)}', RED)], ERROR);
				}
			} else {
				mutex.acquire();
				updateDaFunni(bmap);
				mutex.release();
			}
		});
	}

	public inline function updateDaFunni(graphic:FlxGraphic) {
		loadGraphic(graphic);
		this.setUnstretchedGraphicSize(size, size, false);
		updateHitbox();
		x += 90 - width;
	}
}