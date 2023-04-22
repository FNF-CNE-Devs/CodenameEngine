package funkin.backend.system.macros;

#if macro
import sys.io.Process;
#end

class GitCommitMacro {
	/**
	 * Returns the current commit number
	 */
	public static var commitNumber(get, null):Int;
	/**
	 * Returns the current commit hash
	 */
	public static var commitHash(get, null):String;

	// GETTERS
	#if REGION
	private static inline function get_commitNumber()
		return __getCommitNumber();

	private static inline function get_commitHash()
		return __getCommitHash();
	#end

	// INTERNAL MACROS
	#if REGION
	private static macro function __getCommitHash() {
		#if display
		return macro $v{"-"};
		#else
		try {
			var proc = new Process('git', ['rev-parse', '--short', 'HEAD'], false);
			proc.exitCode(true);

			return macro $v{proc.stdout.readLine()};
		} catch(e) {}
		return macro $v{"-"}
		#end
	}

	private static macro function __getCommitNumber() {
		#if display
		return macro $v{0};
		#else
		try {
			var proc = new Process('git', ['rev-list', 'HEAD', '--count'], false);
			proc.exitCode(true);

			return macro $v{Std.parseInt(proc.stdout.readLine())};
		} catch(e) {}
		return macro $v{0}
		#end
	}
	#end
}