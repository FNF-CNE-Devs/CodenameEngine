package funkin.macros;

class GitCommitMacro {
	public static macro function getCommitNumber() {
		#if display
		return macro $v{0};
		#else
		var proc = new Process('git', ['rev-list', 'HEAD', '--count'], false);
		proc.exitCode(true);

		var c = Std.parseInt(proc.stdout.readLine());
		trace(c);
		return macro $v{c};
		#end
	}
}