package funkin.backend.system.github;

typedef GitHubRelease = {
	/**
	 * Body of the GitHub request (Markdown)
	 */
	var body:String;

	/**
	 * Url of the release (GitHub API)
	 */
	var url:String;

	/**
	 * Url for the assets JSON. Also accessible via `GitHubRelease.assets`
	 */
	var assets_url:String;

	/**
	 * Template URL for asset download link.
	 */
	var upload_url:String;

	/**
	 * Link to the release on the GitHub website.
	 */
	var html_url:String;

	/**
	 * ID of the release.
	 */
	var id:Int;

	/**
	 * Author of the release
	 */
	var author:GitHubUser;

	var node_id:String;

	var tag_name:String;

	var target_commitish:String;

	var name:String;

	var draft:Bool;

	var prerelease:Bool;

	var created_at:String;

	var published_at:String;

	var assets:Array<GitHubAsset>;

	var tarball_url:String;

	var zipball_url:String;

	var reactions:GitHubReactions;
}