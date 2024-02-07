package funkin.backend.system.framerate;

import openfl.text.TextFormat;
import openfl.display.Sprite;
import openfl.text.TextField;
import funkin.backend.system.macros.GitCommitMacro;

class CodenameBuildField extends TextField {
	// make this empty once you guys are done with the project.
	// good luck /gen <3 @crowplexus
	public static final releaseCycle:String = " Beta ";

	public function new() {
		super();
		defaultTextFormat = Framerate.textFormat;
		autoSize = LEFT;
		multiline = wordWrap = false;
		text = 'Codename Engine${releaseCycle}\nCommit ${GitCommitMacro.commitNumber} (${GitCommitMacro.commitHash})';
	}
}
