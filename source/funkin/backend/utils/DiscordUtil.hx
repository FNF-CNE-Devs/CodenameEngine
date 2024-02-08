package funkin.backend.utils;

import funkin.backend.scripting.events.DiscordPresenceUpdateEvent;
import haxe.Json;
import flixel.sound.FlxSound;
#if DISCORD_RPC
import sys.thread.Thread;
import Sys;
import lime.app.Application;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
#end

class DiscordUtil {
	public static var currentID:String = null;
	public static var discordThread:#if DISCORD_RPC Thread #else Dynamic #end = null;
	public static var ready:Bool = false;
	public static var data:DiscordJson = null;
	private static var presence:#if DISCORD_RPC DiscordRichPresence = DiscordRichPresence.create() #else Dynamic = null #end;

	public static function init() {
		#if DISCORD_RPC
		reloadJsonData();
		Application.current.onExit.add(function(exitCode) {
			shutdown();
		});

		discordThread = Thread.create(function() {
			while (true)
			{
				while(!ready) {
					Sys.sleep(1/60);
				}
				trace("Processing Discord RPC...");
				#if DISCORD_DISABLE_IO_THREAD
				Discord.UpdateConnection();
				#end
				Discord.RunCallbacks();
				Sys.sleep(2);
			}
		});
		#end
	}

	public static function reloadJsonData() {
		#if DISCORD_RPC
		data = {};
		var jsonPath = Paths.json("config/discord");
		if (Assets.exists(jsonPath)) {
			try {
				data = Json.parse(Assets.getText(jsonPath));
			} catch(e) {
				Logs.trace('Couldn\'t load Discord RPC configuration: ${e.toString()}', ERROR);
			}
		}
		data.setFieldDefault("clientID", "1027994136193810442");
		data.setFieldDefault("logoKey", "icon");
		data.setFieldDefault("logoText", Application.current.meta.get('title'));

		changeClientID(data.clientID);
		#end
	}

	public static function changePresence(details:String, state:String, ?smallImageKey : String) {
		#if DISCORD_RPC
		presence.state = state;
		presence.details = details;
		presence.smallImageKey = smallImageKey;

		updatePresence();
		#end
	}

	public static function changeSongPresence(details:String, state:String, audio:FlxSound, ?smallImageKey : String) {
		#if DISCORD_RPC
		var start:Float = 0;
		var end:Float = 0;

		if (audio != null && audio.playing) {
			start = Date.now().getTime();
			end = start + (audio.length - audio.time);
		}

		presence.details = details;
		presence.state = state;
		//presence.audio = audio; // hxdiscord_rpc dosen't have this ig?
		presence.smallImageKey = smallImageKey;
		presence.startTimestamp = Std.int(start / 1000);
		presence.endTimestamp = Std.int(end / 1000);
		
		updatePresence();
		#end
	}

	public static function updatePresence() {
		#if DISCORD_RPC
		if (presence.largeImageKey == null){
			var FUCKOFF:String = data.logoKey;
			presence.largeImageKey = FUCKOFF;
		}
		if (presence.largeImageText == null){
			var FUCKOFF:String = data.logoText;
			presence.largeImageText = FUCKOFF;
		}

		#if GLOBAL_SCRIPT
		//var event = funkin.backend.scripting.GlobalScript.event("onDiscordPresenceUpdate", EventManager.get(DiscordPresenceUpdateEvent).recycle(data));
		//if (event.cancelled) return;
		#end

		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence));
		#end
	}
	public static function changeClientID(id:String) {
		#if DISCORD_RPC
		shutdown();
		ready = false;

		var discordHandlers:DiscordEventHandlers = DiscordEventHandlers.create();
		discordHandlers.ready = cpp.Function.fromStaticFunction(onReady);
		discordHandlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		discordHandlers.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize(id, cpp.RawPointer.addressOf(discordHandlers), 1, null);
		currentID = id;
		#end
	}

	public static function shutdown() {
		#if DISCORD_RPC
		if (currentID != null)
			Discord.Shutdown();
		#end
	}


	// HANDLERS
	#if DISCORD_RPC
	static function onReady(request:cpp.RawConstPointer<DiscordUser>) {
		var requestPtr:cpp.Star<DiscordUser> = cpp.ConstPointer.fromRaw(request).ptr;
		Logs.trace('Discord RPC started');
		if (Std.parseInt(cast(requestPtr.discriminator, String)) != 0) //New Discord IDs/Discriminator system
			trace('(Discord) Connected to User (${cast(requestPtr.username, String)}#${cast(requestPtr.discriminator, String)})');
		else //Old discriminators
			trace('(Discord) Connected to User (${cast(requestPtr.username, String)})');
		ready = true;
	}

	static function onError(_code:Int, _message:cpp.ConstCharStar) {
		Logs.trace('Discord RPC Error: ${cast(_message, String)} (Code: $_code)', ERROR);
	}

	static function onDisconnected(_code:Int, _message:cpp.ConstCharStar) {
		Logs.trace('Discord RPC Disconnected: ${cast(_message, String)} (Code: $_code)', WARNING);
	}
	#end
}

typedef DiscordJson = {
	var ?clientID:String;
	var ?logoKey:String;
	var ?logoText:String;
}

// taken from old discord-rpc...
typedef DiscordPresenceOptions = {
	// has to make them all cpp.ConstCharStar cuz 
	/*
	Error: DiscordUtil.cpp
	./src/funkin/backend/utils/DiscordUtil.cpp(259): error C2440: 'initializing': cannot convert from 'hx::Val' to 'const char *'
	./src/funkin/backend/utils/DiscordUtil.cpp(259): note: No user-defined-conversion operator available that can perform this conversion, or the operator cannot be called
	./src/funkin/backend/utils/DiscordUtil.cpp(261): error C2440: 'initializing': cannot convert from 'hx::Val' to 'const char *'
	./src/funkin/backend/utils/DiscordUtil.cpp(261): note: No user-defined-conversion operator available that can perform this conversion, or the operator cannot be called
	./src/funkin/backend/utils/DiscordUtil.cpp(263): error C2440: 'initializing': cannot convert from 'hx::Val' to 'const char *'
	./src/funkin/backend/utils/DiscordUtil.cpp(263): note: No user-defined-conversion operator available that can perform this conversion, or the operator cannot be called
	./src/funkin/backend/utils/DiscordUtil.cpp(265): error C2440: 'initializing': cannot convert from 'hx::Val' to 'const char *'
	./src/funkin/backend/utils/DiscordUtil.cpp(265): note: No user-defined-conversion operator available that can perform this conversion, or the operator cannot be called
	./src/funkin/backend/utils/DiscordUtil.cpp(267): error C2440: 'initializing': cannot convert from 'hx::Val' to 'const char *'
	./src/funkin/backend/utils/DiscordUtil.cpp(267): note: No user-defined-conversion operator available that can perform this conversion, or the operator cannot be called
	./src/funkin/backend/utils/DiscordUtil.cpp(269): error C2440: 'initializing': cannot convert from 'hx::Val' to 'const char *'
	./src/funkin/backend/utils/DiscordUtil.cpp(269): note: No user-defined-conversion operator available that can perform this conversion, or the operator cannot be called
	*/

    @:optional var state:cpp.ConstCharStar; // String
    @:optional var details:cpp.ConstCharStar; // String
    @:optional var startTimestamp:Dynamic; // Int uhh haxe said to use cpp.Int64 here dunno
    @:optional var endTimestamp:Dynamic; // Int
    @:optional var largeImageKey:cpp.ConstCharStar; // String
    @:optional var largeImageText:cpp.ConstCharStar; // String
    @:optional var smallImageKey:cpp.ConstCharStar; // String
    @:optional var smallImageText:cpp.ConstCharStar; // String
}