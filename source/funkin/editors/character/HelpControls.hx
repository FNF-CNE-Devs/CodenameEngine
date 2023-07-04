package funkin.editors.character;

class HelpControls extends UISubstateWindow
{

	var helpTextTitles:Array<String> = [
		"Camera:",
		"Offset:",
		"Animation:"
	];
	var helpTexts:Array<String> = [
		"\n\n- WASD: Move camera\n\n- I & O: Zoom In & Out.",
		"\n\n- Arrows keys: Move the offset of the current\nanimation.\n\n- Left Click: Move the offset of the character",
		"\n\n- K & L: Switch to previous & next animation\n\n- SPACE: Play current animation.\n\n"
	];

	var curPage:Int = 0;
	public function new()
	{
		super();
	}

	public override function create()
	{
		winTitle = 'Help: Controls';
		winWidth = 960;

		super.create();

		var helpTextTitle = new UIText(windowSpr.x + 25, windowSpr.y + 45, -1, helpTextTitles[0], 36);
		add(helpTextTitle);

		var helpText = new UIText(windowSpr.x + 25, windowSpr.y + 50, -1, helpTexts[0], 24);
		add(helpText);

		var pageText = new UIText(855, windowSpr.y + 460, -1, '${curPage+1}/${helpTexts.length}', 24);
		add(pageText);

		var rightButton = new UIButton(885, windowSpr.y + 500, ">", function()
		{
			if(curPage == helpTexts.length-1)
				curPage = 0;
			else
				curPage++;

			pageText.text = '${curPage+1}/${helpTexts.length}';
			helpText.text = helpTexts[curPage];
			helpTextTitle.text = helpTextTitles[curPage];
		}, 32);

		var leftButton = new UIButton(845, windowSpr.y + 500, "<", function()
		{
			if(curPage == 0)
				curPage = helpTexts.length-1;
			else
				curPage--;

			pageText.text = '${curPage+1}/${helpTexts.length}';
			helpText.text = helpTexts[curPage];
			helpTextTitle.text = helpTextTitles[curPage];
		}, 32);

		var closeButton = new UIButton(helpText.x, windowSpr.y + 500, "Close", function()
		{
			close();
		});
		add(closeButton);
		add(leftButton);
		add(rightButton);
	}
}
