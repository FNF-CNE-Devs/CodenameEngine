package funkin.backend.utils;

import funkin.backend.scripting.events.DiscordPresenceUpdateEvent;
import haxe.Json;
import flixel.sound.FlxSound;
#if DISCORD_RPC
import discord_rpc.DiscordRpc;
import sys.thread.Thread;
import Sys;
import lime.app.Application;
#end

class DiscordUtil {
	public static var currentID:String = null;
	public static var discordThread:#if DISCORD_RPC Thread #else Dynamic #end = null;
	public static var ready:Bool = false;
	public static var data:DiscordJson = null;

	public static function init() {
		#if DISCORD_RPC
		reloadJsonData();
		discordThread = Thread.create(function() {
			while (true)
			{
				while(!ready) {
					Sys.sleep(1/60);
				}
				trace("Processing Discord RPC...");
				DiscordRpc.process();
				Sys.sleep(2);
			}
		});

		Application.current.onExit.add(function(exitCode) {
			shutdown();
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
		changePresenceAdvanced({
			state: state,
			details: details,
			smallImageKey: smallImageKey
		});
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

		changePresenceAdvanced({
			state: state,
			details: details,
			smallImageKey: smallImageKey,
			startTimestamp: Std.int(start / 1000),
			endTimestamp: Std.int(end / 1000)
		});
		#end
	}

	public static function changePresenceAdvanced(data:#if DISCORD_RPC DiscordPresenceOptions #else Dynamic #end) {
		#if DISCORD_RPC
		if (data == null) return;

		if (data.largeImageKey == null)
			data.largeImageKey = DiscordUtil.data.logoKey;
		if (data.largeImageText == null)
			data.largeImageText = DiscordUtil.data.logoText;

		#if GLOBAL_SCRIPT
		var event = funkin.backend.scripting.GlobalScript.event("onDiscordPresenceUpdate", EventManager.get(DiscordPresenceUpdateEvent).recycle(data));
		if (event.cancelled) return;
		#end

		DiscordRpc.presence(data);
		#end
	}
	public static function changeClientID(id:String) {
		#if DISCORD_RPC
		if (currentID != null) {
			DiscordRpc.shutdown();
		}

		ready = false;

		DiscordRpc.start({
			clientID: id,
			onReady: function() {
				Logs.trace('Discord RPC started');
				ready = true;
			},
			onError: onError,
			onDisconnected: onDisconnected
		});
		currentID = id;

		#end
	}

	public static function shutdown() {
		#if DISCORD_RPC
		DiscordRpc.shutdown();
		#end
	}


	// HANDLERS
	#if DISCORD_RPC
	static function onError(_code:Int, _message:String) {
		Logs.trace('Discord RPC Error: ${_message} (Code: $_code)', ERROR);
	}

	static function onDisconnected(_code:Int, _message:String) {
		Logs.trace('Discord RPC Disconnected: ${_message} (Code: $_code)', WARNING);
	}
	#end
}

typedef DiscordJson = {
	var ?clientID:String;
	var ?logoKey:String;
	var ?logoText:String;
}