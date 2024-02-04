package funkin.options.type;

import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import funkin.backend.shaders.CustomShader;
import funkin.backend.system.github.GitHub;
import flixel.util.FlxColor;

class GithubIconOption extends TextOption
{
	public var user(default, null):Dynamic;  // Can possibly be GitHubUser or GitHubContributor
	public var icon:GithubUserIcon = null;
	public var usePortrait(default, set) = true;

	public function set_usePortrait(value:Bool)
	{
		if (icon == null) return usePortrait = false;
		icon.shader = (value ? new CustomShader('engine/circleProfilePicture') : null);
		return usePortrait = value;
	}

	public function new(user:Dynamic, desc:String, ?callback:Void->Void, ?customName:String, size:Int = 96, usePortrait:Bool = true) {
		super(customName == null ? user.login : customName, desc, callback == null ? function() CoolUtil.openURL(user.html_url) : callback);
		this.user = user;
		this.icon = new GithubUserIcon(user, size);
		this.usePortrait = usePortrait;
		add(icon);
	}
}

class GithubUserIcon extends FlxSprite
{
	private var loading:Bool = false;
	private var user:Dynamic;
	private var size:Int;

	public override function new(user:Dynamic, size:Int = 96) {
		this.user = user;
		this.size = size;
		super();
		makeGraphic(size, size, FlxColor.TRANSPARENT);
		antialiasing = true;
	}

	final mutex = new sys.thread.Mutex();
	override function drawComplex(camera:FlxCamera):Void {  // Making the image downlaod only if the player actually sees it on the screeeeen  - Nex
		if(!loading) {
			loading = true;
			Main.execAsync(function() {
				var key:String = 'GITHUB-USER:${user.login}';
				var bmap:Dynamic = FlxG.bitmap.get(key);

				if(bmap == null) {
					trace('Downloading avatar: ${user.login}');
					var unfLink:Bool = StringTools.endsWith(user.avatar_url, '.png');
					var planB:Bool = true;

					var bytes = null;
					if(unfLink) {
						try bytes = GitHub.__requestBytesOnGitHubServers('${user.avatar_url}?size=$size')
						catch(e) Logs.traceColored([Logs.logText('Failed to download github pfp for ${user.login}: ${CoolUtil.removeIP(e.message)} - (Retrying using the api..)', RED)], ERROR);

						if(bytes != null) {
							bmap = BitmapData.fromBytes(bytes);
							planB = false;
						}
					}

					if(planB) {
						if(unfLink) user = GitHub.getUser(user.login, function(e) Logs.traceColored([Logs.logText('Failed to download github user info for ${user.login}: ${CoolUtil.removeIP(e.message)}', RED)], ERROR));  // Api part - Nex
						try bytes = GitHub.__requestBytesOnGitHubServers('${user.avatar_url}&size=$size')
						catch(e) Logs.traceColored([Logs.logText('Failed to download github pfp for ${user.login}: ${CoolUtil.removeIP(e.message)}', RED)], ERROR);

						if(bytes != null) bmap = BitmapData.fromBytes(bytes);
					}

					if(bmap != null) try {
						mutex.acquire();  // Avoiding critical section  - Nex
						var leGraphic:FlxGraphic = FlxG.bitmap.add(bmap, false, key);
						leGraphic.persist = true;
						updateDaFunni(leGraphic);
						bmap = null;
						mutex.release();
					} catch(e) {
						Logs.traceColored([Logs.logText('Failed to update the pfp for ${user.login}: ${e.message}', RED)], ERROR);
					}
				} else {
					mutex.acquire();
					updateDaFunni(bmap);
					mutex.release();
				}
			});
		}
		super.drawComplex(camera);
	}

	public inline function updateDaFunni(graphic:FlxGraphic) {
		loadGraphic(graphic);
		this.setUnstretchedGraphicSize(size, size, false);
		updateHitbox();
		x += 90 - width;
	}
}