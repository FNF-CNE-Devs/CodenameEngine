package funkin.editors.character;

import funkin.options.type.OptionType;
import funkin.options.type.NewOption;
import flixel.util.FlxColor;
import funkin.game.Character;
import funkin.backend.chart.Chart;
import funkin.options.type.TextOption;
import funkin.options.type.IconOption;
import funkin.options.OptionsScreen;

class CharacterSelection extends EditorTreeMenu
{
	public override function create()
	{
		bgType = "charter";
		super.create();

		var modsList:Array<String> = Character.getList(true);

		var list:Array<OptionType> = [
			for (char in (modsList.length == 0 ? Character.getList(false) : modsList))
				new IconOption(char, "Press ACCEPT to edit this character.", Character.getIconFromCharName(char),
			 	function() {
					FlxG.switchState(new CharacterEditor(char));
				})
		];

		list.insert(0, new NewOption("New Character", "New Character", function() {
			openSubState(new CharacterCreationSubstate());
		}));

		main = new OptionsScreen("Character Editor", "Select a character to edit", list);

		DiscordUtil.call("onEditorTreeLoaded", ["Character Editor"]);
	}

	override function createPost() {
		super.createPost();

		main.changeSelection(1);
	}
}

class CharacterCreationSubstate extends UISubstateWindow {
	public function new() {
		super();
	}

	public override function create() {
		winTitle = "Creating New Character";

		winWidth = 380;
		winHeight = 250;
		
		super.create();
		//var spliceSprite:UISliceSprite = new UISliceSprite(650, 350, 30, 30, "editors/ui/context-bg");
		//add(spliceSprite);

		var textBox:UITextBox = new UITextBox(30, 130, "");
		add(textBox);

		add(new UIText(textBox.x, textBox.y - 20, textBox.label.width, "Your character's image file name:"));

		add(new UIButton(textBox.x, textBox.y - 80, "Create New Character", function() {
			if (openfl.utils.Assets.exists(Paths.image('characters/' + textBox.label.text))) {
				#if sys
				CoolUtil.safeSaveFile(
					'${Paths.getAssetsRoot()}/data/characters/${textBox.label.text}.xml',
'
					<!DOCTYPE codename-engine-character>
					<character isPlayer="false" flipX="false" holdTime="6.1" color="#AF66CE">
						<anim name="idle"      anim="Dad idle dance"      fps="24" loop="false" x="0" y="0"/>
						<anim name="singUP"    anim="Dad Sing note UP"    fps="24" loop="false" x="-6" y="50"/>
						<anim name="singLEFT"  anim="dad sing note right"  fps="24" loop="false" x="-10" y="10"/>
						<anim name="singRIGHT" anim="Dad Sing Note LEFT" fps="24" loop="false" x="0" y="27"/>
						<anim name="singDOWN"  anim="Dad Sing Note DOWN"  fps="24" loop="false" x="0" y="-30"/>
					</character>'
				);
				#else
				openSubState(new SaveSubstate('
				<!DOCTYPE codename-engine-character>
					<character isPlayer="false" flipX="false" holdTime="6.1" color="#AF66CE">
						<anim name="idle"      anim="Dad idle dance"      fps="24" loop="false" x="0" y="0"/>
						<anim name="singUP"    anim="Dad Sing note UP"    fps="24" loop="false" x="-6" y="50"/>
						<anim name="singLEFT"  anim="dad sing note right"  fps="24" loop="false" x="-10" y="10"/>
						<anim name="singRIGHT" anim="Dad Sing Note LEFT" fps="24" loop="false" x="0" y="27"/>
						<anim name="singDOWN"  anim="Dad Sing Note DOWN"  fps="24" loop="false" x="0" y="-30"/>
					</character>',
				{
					defaultSaveFile: textBox.label.text + '.xml'
				}));
				#end

				CharacterEditor.__character = textBox.label.text;
				FlxG.switchState(new CharacterEditor(textBox.label.text));
			} else {
				openSubState(new UIWarningSubstate("Warning!", "Your character's image file doesn't exist.", [
					{
						label: "OK",
						onClick: function(t) {
							trace("OK clicked!");
						}
					}
				]));
			}
		}, 130, 32));

		var closeButton:UIButton = new UIButton(textBox.x, textBox.y + textBox.label.height + 50, "Cancel", function() {
			close();
		}, 125);
		add(closeButton);
		closeButton.color = 0xFFFF0000;
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		parent.persistentUpdate = false;
	}
}