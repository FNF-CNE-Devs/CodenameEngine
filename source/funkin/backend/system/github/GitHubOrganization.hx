package funkin.backend.system.github;

import funkin.backend.system.github.GitHubUser.GitHubUserType;

typedef GitHubOrganization = {
	var login:String;
	var id:Int;
	var node_id:String;
	var url:String;
	var repos_url:String;
	var events_url:String;
	var hooks_url:String;
	var issues_url:String;
	var members_url:String;
	var public_members_url:String;
	var avatar_url:String;
	var description:String;
	var name:String;
	var company:String;
	var blog:String;
	var location:String;
	var email:String;
	var twitter_username:String;
	var is_verified:Bool;
	var has_organization_projects:Bool;
	var has_repository_projects:Bool;
	var public_repos:Int;
	var public_gists:Int;
	var followers:Int;
	var following:Int;
	var html_url:String;
	var created_at:String;
	var updated_at:String;
	var archived_at:String;
	var type:GitHubUserType;
}