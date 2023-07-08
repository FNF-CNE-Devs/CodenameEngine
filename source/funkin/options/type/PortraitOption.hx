package funkin.options.type;

import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import funkin.backend.shaders.CustomShader;
import funkin.backend.system.github.GitHubContributor;
import funkin.backend.system.github.GitHub;

class PortraitOption extends TextOption {
	public var portrait:FlxSprite = null;

	public function new(name:String, desc:String, callback:Void->Void, ?graphic:FlxGraphic, size:Int = 96) {
		super(name, desc, callback);
		if (graphic != null) addPortrait(graphic, size);
	}

	public function addPortrait(graphic:FlxGraphic, size:Int = 96) {
		if (portrait == null) {
			portrait = new FlxSprite();
			portrait.antialiasing = true;
			portrait.shader = new CustomShader('engine/circleProfilePicture');
			add(portrait);
		}
		portrait.loadGraphic(graphic);
		portrait.setUnstretchedGraphicSize(size, size, false);
		portrait.updateHitbox();
		portrait.setPosition(90 - portrait.width, 0);
	}

	public function loadFromGithub(user:GitHubContributor, size:Int = 96) {
		//Main.execAsync(function() {
		var bytes = GitHub.__requestBytesOnGitHubServers('${user.avatar_url}&size=$size');
		var bmap = BitmapData.fromBytes(bytes);
		addPortrait(FlxG.bitmap.add(bmap, false, 'GITHUB-USER:${user.login}'), size);
		//});
	}
}