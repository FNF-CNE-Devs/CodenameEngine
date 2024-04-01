package flixel.text;

import flixel.math.FlxRandom;
import haxe.Int64;

using StringTools;

class Uwuifier {
	public static var faces = [
		";;w;;",
		"OwO",
		"UwU",
		">w<",
		"^w^",
		"^-^",
		":3",
		"x3",
		":3c",
	];
	public static var exclamations = ["!?", "?!!", "?!?1", "!!11", "?!?!"];
	public static var actions = [
		"*blushes*",
		"*whispers to self*",
		"*cries*",
		"*screams*",
		"*sweats*",
		"*runs away*",
		"*screeches*",
		"*walks away*",
		"*looks at you*",
		"*huggles tightly*",
		"*boops your nose*",
	];
	public static var uwuMap:Array<Dynamic> = [
		[~/(?:r|l)/g, "w"],
		[~/(?:R|L)/g, "W"],
		[~/n([aeiou])/g, "ny$1"],
		[~/N([aeiou])/g, "Ny$1"],
		[~/N([AEIOU])/g, "NY$1"],
		[~/ove/g, "uv"],
	];

	private static var _spacesModifier = { faces: 0.05, actions: 0.075, stutters: 0.1 };
	private static var _wordsModifier:Float = 1;
	private static var _exclamationsModifier:Float = 1;

	public static function uwuifyWords(sentence: String): String {
		var words = sentence.split(" ");

		var uwuifiedSentence = words.map((word) -> {
			//if (isAt(word)) return word;
			if (word == "@") return word;
			//if (isUri(word)) return word;

			var seed = new Seed(word);

			for (aa in uwuMap) {
				var oldWord = aa[0];
				var newWord = aa[1];

				// Generate a random value for every map so words will be partly uwuified instead of not at all
				if (seed.random() > _wordsModifier) continue;

				//trace(oldWord, newWord, word);
				word = oldWord.replace(word, newWord);
				//trace(oldWord, newWord, word);
			}

			return word;
		}).join(" ");

		return uwuifiedSentence;
	}

	public static function uwuifySpaces(sentence: String): String {
		var words = sentence.split(" ");

		var faceThreshold = _spacesModifier.faces;
		var actionThreshold = _spacesModifier.actions + faceThreshold;
		var stutterThreshold = _spacesModifier.stutters + actionThreshold;

		var index = 0;
		var uwuifiedSentence = words.map((word) -> {
			var seed = new Seed(word);
			var random = seed.random();

			var firstCharacter = word.charAt(0);

			function checkCapital() {
				// Check if we should remove the first capital letter
				if (firstCharacter != firstCharacter.toUpperCase()) return;
				// if word has higher than 50% upper case
				if (getCapitalPercentage(word) > 0.5) return;

				// If it's the first word
				if (index == 0) {
					// Remove the first capital letter
					word = firstCharacter.toLowerCase() + word.substr(1);
				} else {
					var previousWord = words[index - 1];
					var previousWordLastChar = previousWord.charAt(previousWord.length - 1);
					var prevWordEndsWithPunctuation = (~/[.!?\\-]/).match(
						previousWordLastChar
					);

					if (!prevWordEndsWithPunctuation) return;
					word = firstCharacter.toLowerCase() + word.substr(1);
				}
			}

			if (random <= faceThreshold && faces.length > 0) {
				// Add random face before the word
				var a = seed.randomInt(0, faces.length - 1);
				//trace(a, faces.length, faces);
				word += " " + faces[a];
				checkCapital();
			} else if (random <= actionThreshold && actions.length > 0) {
				// Add random action before the word
				var a = seed.randomInt(0, actions.length - 1);
				//trace(a, actions.length, actions);
				word += " " + actions[a];
				checkCapital();
			} else if (random <= stutterThreshold/* && !isUri(word)*/) {
				// Add stutter with a length between 0 and 2
				var stutter = seed.randomInt(0, 2);
				index++;
				return [for (i in 0...stutter) (firstCharacter + "-")].join("") + word;
				//return (firstCharacter + "-").repeat(stutter) + word;
			}

			index++;

			return word;
		}).join(" ");

		return uwuifiedSentence;
	}

	public static function uwuifyExclamations(sentence: String): String {
		var words = sentence.split(" ");
		var pattern = ~/[?!]+$/;

		var uwuifiedSentence = words.map((word) -> {
			var seed = new Seed(word);

			// If there are no exclamations return
			if (
				!pattern.match(word) || seed.random() > _exclamationsModifier
			) {
				return word;
			}

			word = pattern.replace(word, "");//.replace(pattern, "");
			word += exclamations[seed.randomInt(0, exclamations.length - 1)];

			return word;
		}).join(" ");

		return uwuifiedSentence;
	}

	public static var disableUWU:Bool = false;

	public static function uwuifySentence(sentence: String): String {
		if(sentence.trim().length == 0 || disableUWU) return sentence;

		var uwuifiedString = sentence;

		uwuifiedString = uwuifyWords(uwuifiedString);
		//uwuifiedString = uwuifyExclamations(uwuifiedString);
		uwuifiedString = uwuifySpaces(uwuifiedString);

		//trace(uwuifiedString);

		return uwuifiedString;
	}

	static function isLetter(char: String) {
		//return ~/^\p{L}/u.match(char);
		return ~/^[a-zA-Z]/i.match(char);
	}
	static function isUpperCase(char: String) {
		return char == char.toUpperCase();
	}

	static function getCapitalPercentage(str: String): Float {
		var totalLetters = 0;
		var upperLetters = 0;

		for (currentLetter in str.split("")) {
			if (!isLetter(currentLetter)) continue;

			if (isUpperCase(currentLetter)) {
				upperLetters++;
			}

			totalLetters++;
		}

		return upperLetters / totalLetters;
	}
}

class Crc32 {
	var crc:Int;

	public inline function new() {
		crc = 0xFFFFFFFF;
	}

	public inline function update(b:String, pos, len) {
		//var b = b.getData();
		for (i in pos...pos + len) {
			var tmp = (crc ^ b.charCodeAt(i)) & 0xFF;
			for (j in 0...8)
				tmp = (tmp >>> 1) ^ (-(tmp & 1) & 0xEDB88320);
			crc = (crc >>> 8) ^ tmp;
		}
	}

	public inline function get() {
		return crc ^ 0xFFFFFFFF;
	}
	public inline function getSinged() {
		return crc ^ 0xFFFFFFFF;
	}

	/**
		Calculates the CRC32 of the given data bytes
	**/
	public static function make(data:String):Int {
		var c = new Crc32();
		c.update(data, 0, data.length);
		var a = c.getSinged();
		if(a < 0) {
			a = -a;
		}
		return a;
	}
}


class Seed {
	private var seeder: FlxRandom;

	public function new(seed: String) {
		this.seeder = new FlxRandom();
		seeder.initialSeed = Crc32.make(seed);
		//trace(seeder.initialSeed, seed, Crc32.make(seed));
	}

	public function random(min:Float = 0, max:Float = 1): Float {
		// Make sure the minimum and maximum values are correct
		if (min > max) {
			throw ("The minimum value must be below the maximum value");
		}
		if (min == max) {
			throw ("The minimum value cannot equal the maximum value");
		}

		return this.denormalize(seeder.float(0, 1), min, max);
	}

	public function randomInt(min:Float = 0, max:Float = 1): Int {
		return Math.round(this.random(min, max));
	}

	private function denormalize(value: Float, min: Float, max: Float): Float {
		return value * (max - min) + min;
	}

	/* private function imul(a:Int, b:Int) {
		return a * (b & 65535) + (a * (b >>> 16) << 16 | 0) | 0;
	}
	private function imul64(a:Int64, b:Int64) {
		return Int64.mul(a, b);//a * (b & 65535) + (a * (b >>> 16) << 16 | 0) | 0;
	}

	// https://github.com/bryc/code/blob/master/jshash/PRNGs.md
	private function xmur3(str: String): Void -> Int64 {
		var h = Int64.make(0, 1779033703) ^ Int64.make(0, str.length);

		//for (let i = 0; i < str.length; i++) {
		var aa = Int64.parseString("3432918353");
		for(i in 0...str.length) {
			h = imul64(h ^ Int64.make(0, str.charCodeAt(i)), aa);
			h = h << 13 | h >>> 19;
		}

		var bb = Int64.parseString("2246822507");
		var cc = Int64.parseString("3266489909");

		return () -> {
			h = imul64(h ^ h >>> 16, bb);
			h = imul64(h ^ h >>> 13, cc);
			return (h ^= h >>> 16) >>> 0;
		};
	}

	static function toint32(a:Int64):Int64 {
		return a & 0xFFFFFFFF;//Int64.make(0, Int64.toInt(a & 0xFFFFFFFF));
	}

	// https://github.com/bryc/code/blob/master/jshash/PRNGs.md
	private function sfc32(): Int {
		var a = this.seeder();
		var b = this.seeder();
		var c = this.seeder();
		var d = this.seeder();

		a = toint32(a);
		b = toint32(b);
		c = toint32(c);
		d = toint32(d);
		// a >>>= 0;
		// b >>>= 0;
		// c >>>= 0;
		// d >>>= 0;
		var t = (a + b) | 0;
		a = b ^ (toint32(b >> 9));
		b = (c + (c << 3)) | 0;
		c = (c << 21) | (toint32(c >> 11));
		d = (d + 1) | 0;
		t = (t + d) | 0;
		c = (c + t) | 0;
		return Int64.toInt(toint32(toint32(t) / Int64.parseString("4294967296")));
	}*/
}

/*class Seed {
	private var seeder: Void -> Int64;

	public function new(seed: String) {
		this.seeder = this.xmur3(seed);
	}

	public function random(min = 0, max = 1): Float {
		// Make sure the minimum and maximum values are correct
		if (min > max) {
			throw ("The minimum value must be below the maximum value");
		}
		if (min == max) {
			throw ("The minimum value cannot equal the maximum value");
		}

		return this.denormalize(this.sfc32(), min, max);
	}

	public function randomInt(min = 0, max = 1): Int {
		return Math.round(this.random(min, max));
	}

	private function denormalize(value: Float, min: Float, max: Float): Float {
		return value * (max - min) + min;
	}

	private function imul(a:Int, b:Int) {
		return a * (b & 65535) + (a * (b >>> 16) << 16 | 0) | 0;
	}
	private function imul64(a:Int64, b:Int64) {
		return Int64.mul(a, b);//a * (b & 65535) + (a * (b >>> 16) << 16 | 0) | 0;
	}

	// https://github.com/bryc/code/blob/master/jshash/PRNGs.md
	private function xmur3(str: String): Void -> Int64 {
		var h = Int64.make(0, 1779033703) ^ Int64.make(0, str.length);

		//for (let i = 0; i < str.length; i++) {
		var aa = Int64.parseString("3432918353");
		for(i in 0...str.length) {
			h = imul64(h ^ Int64.make(0, str.charCodeAt(i)), aa);
			h = h << 13 | h >>> 19;
		}

		var bb = Int64.parseString("2246822507");
		var cc = Int64.parseString("3266489909");

		return () -> {
			h = imul64(h ^ h >>> 16, bb);
			h = imul64(h ^ h >>> 13, cc);
			return (h ^= h >>> 16) >>> 0;
		};
	}

	static function toint32(a:Int64):Int64 {
		return a & 0xFFFFFFFF;//Int64.make(0, Int64.toInt(a & 0xFFFFFFFF));
	}

	// https://github.com/bryc/code/blob/master/jshash/PRNGs.md
	private function sfc32(): Int {
		var a = this.seeder();
		var b = this.seeder();
		var c = this.seeder();
		var d = this.seeder();

		a = toint32(a);
		b = toint32(b);
		c = toint32(c);
		d = toint32(d);
		// a >>>= 0;
		// b >>>= 0;
		// c >>>= 0;
		// d >>>= 0;
		var t = (a + b) | 0;
		a = b ^ (toint32(b >> 9));
		b = (c + (c << 3)) | 0;
		c = (c << 21) | (toint32(c >> 11));
		d = (d + 1) | 0;
		t = (t + d) | 0;
		c = (c + t) | 0;
		return Int64.toInt(toint32(toint32(t) / Int64.parseString("4294967296")));
	}
}*/