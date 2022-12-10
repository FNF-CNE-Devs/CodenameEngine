package funkin.options.categories;

class SaveDataOptions extends OptionsScreen
{
	public override function create()
	{
		options = [
			new TextOption("Reset Save Data", "Select this option to reset save data. This will remove all of your highscores", function()
			{
				// TODO!!
			})
		];
		super.create();
	}
}
