package funkin.backend.scripting.events;

#if DISCORD_RPC
import discord_rpc.DiscordRpc.DiscordPresenceOptions;
#end

final class DiscordPresenceUpdateEvent extends CancellableEvent {
	/**
	 * Object containing all of the data for the presence. Can be altered.
	 */
	public var presenceData:#if DISCORD_RPC DiscordPresenceOptions #else Dynamic #end;
}