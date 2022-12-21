package funkin.options.categories;

class GameplayOptions extends OptionsScreen {
    public override function create() {
        options = [
            new Checkbox(
                "Downscroll",
                "If checked, notes will go from up to down instead of down to up, like if they were falling",
                "downscroll"),
            new Checkbox(
                "Naughtyness",
                "If unchecked, will censor Week 7 cutscenes",
                "naughtyness"),
            new Checkbox(
                "Camera Zoom on Beat",
                "If unchecked, will disable camera zooming every 4 beats",
                "camZoomOnBeat"),
        ];
        super.create();
    }
}