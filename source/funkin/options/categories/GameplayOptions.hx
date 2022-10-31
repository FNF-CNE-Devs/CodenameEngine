package funkin.options.categories;

class GameplayOptions extends OptionsScreen {
    public override function create() {
        options = [
            new Checkbox("Downscroll", "downscroll"),
            new Checkbox("Auto Pause", "autoPause"),
        ];
        super.create();
    }
}