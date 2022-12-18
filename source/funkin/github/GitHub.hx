package funkin.github;

import haxe.Json;
import haxe.Exception;
import haxe.Http;

// TODO: Document further and perhaps make this a Haxelib.
class GitHub
{
	/**
	 * Gets all the releases from a specific GitHub repository using the GitHub API.
	 * @param user 
	 * @param repository 
	 * @return Releases
	 */
	public static function getReleases(user:String, repository:String, ?onError:Exception->Void):Array<GitHubRelease>
	{
		try
		{
			var url = 'https://api.github.com/repos/${user}/${repository}/releases';

			var data = Json.parse(__requestOnGitHubServers(url));
			if (!(data is Array))
				throw __parseGitHubException(data);

			return data;
		}
		catch (e)
		{
			if (onError != null)
				onError(e);
		}
		return [];
	}

	/**
	 * Filters all releases gotten by `getReleases`
	 * @param releases Releases
	 * @param keepPrereleases Whenever to keep Pre-Releases.
	 * @param keepDrafts Whenever to keep Drafts.
	 * @return Filtered releases.
	 */
	public static inline function filterReleases(releases:Array<GitHubRelease>, keepPrereleases:Bool = true, keepDrafts:Bool = false)
		return [
			for (release in releases)
				if (release != null
					&& (!release.prerelease || (release.prerelease && keepPrereleases))
					&& (!release.draft || (release.draft && keepDrafts))) release
		];

	private static function __requestOnGitHubServers(url:String)
	{
		var h = new Http(url);
		h.setHeader("User-Agent", "request");
		var r = null;
		h.onData = function(d)
		{
			r = d;
		}
		h.onError = function(e)
		{
			throw e;
		}
		h.request(false);
		return r;
	}

	private static function __parseGitHubException(obj:Dynamic):GitHubException
	{
		var msg:String = "(No message)";
		var url:String = "(No API url)";
		if (Reflect.hasField(obj, "message"))
			msg = Reflect.field(obj, "message");
		if (Reflect.hasField(obj, "documentation_url"))
			url = Reflect.field(obj, "documentation_url");
		return new GitHubException(msg, url);
	}
}
