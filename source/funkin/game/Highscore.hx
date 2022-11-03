package funkin.game;

import flixel.FlxG;

class Highscore
{
	public static var songScores:Map<String, SongScore> = new Map();
	public static var weekScores:Map<String, SongScore> = new Map();

	public static function saveScore(song:String, score:SongScore, ?diff:String = "normal"):Void
	{
		prepareScore(score);
		var daSong:String = formatSong(song, diff);

		if (!songScores.exists(daSong) || songScores.get(daSong).score < score.score)
			setScore(daSong, score);
	}

	public static function saveWeekScore(weekName:String, score:SongScore, ?diff:String = "normal"):Void
	{
		prepareScore(score);
		var daWeek:String = formatSong(weekName, diff);

		if (!weekScores.exists(daWeek) || weekScores.get(daWeek).score < score.score)
			setWeekScore(daWeek, score);
	}

	static function setScore(song:String, score:SongScore):Void
	{
		if (score == null) return;
		songScores.set(song, score);
		save();
	}

	static function setWeekScore(song:String, score:SongScore):Void
	{
		if (score == null) return;
		weekScores.set(song, score);
		save();
	}

	public static function save() {
		FlxG.save.data.songScores = songScores;
		FlxG.save.data.weekScores = weekScores;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:String):String
	{
		var daSong:String = song.toLowerCase();
		diff = diff.toLowerCase();
		if (diff != "normal")
			daSong += '-$diff';
		return daSong;
	}

	public static function getScore(song:String, diff:String):SongScore
	{
		var daSong = formatSong(song, diff);
		if (!songScores.exists(daSong))
			setScore(daSong, {});

		return prepareScore(songScores.get(daSong));
	}

	public static function getWeekScore(week:String, diff:String):SongScore
	{
		var daWeek = formatSong(week, diff);
		if (!weekScores.exists(daWeek))
			setScore(daWeek, {});

		return prepareScore(weekScores.get(daWeek));
	}

	public static function prepareScore(score:SongScore):SongScore {
		if (score == null) score = {};

		score.setFieldDefault('score', 0);
		score.setFieldDefault('accuracy', 0);
		score.setFieldDefault('misses', 0);
		score.setFieldDefault('hits', new Map<String, Int>());

		return score;
	}
	public static function load():Void
	{
		songScores = CoolUtil.getDefault(FlxG.save.data.songScores, new Map<String, SongScore>());
		weekScores = CoolUtil.getDefault(FlxG.save.data.weekScores, new Map<String, SongScore>());
		
		for(k=>e in songScores)
			if (e is Int)
				songScores.remove(k);
	}
}


typedef SongScore = {
	@:optional var score:Int;
	@:optional var accuracy:Float;
	@:optional var misses:Int;
	@:optional var hits:Map<String, Int>;
}