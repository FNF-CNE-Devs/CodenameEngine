package funkin.options.categories;

class GameplayOptions extends OptionsScreen {
    public override function create() {
        options = [
            new Checkbox(
                "Downscroll",
                "If checked, notes will go from up to down instead of down to up, like if they were falling",
                "downscroll"),
            new Checkbox(
                "Auto Pause",
                "If checked, switching windows will pause the game",
                "autoPause"),
            new Checkbox(
                "Antialiasing",
                "If unchecked, will disable antialiasing on every sprite. Can boost performances at the cost of sharper, more pixely sprites",
                "antialiasing"),
        ];
        super.create();
    }
}