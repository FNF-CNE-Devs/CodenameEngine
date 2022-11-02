package funkin.options.categories;

class BehaviourOptions extends OptionsScreen {
    public override function create() {
        options = [
            new Checkbox(
                "Naughtyness",
                "If unchecked, will censor Week 7 cutscenes",
                "naughtyness"),
            new Checkbox(
                "Flashing Menu",
                "If unchecked, will disable menu flashing when you select an option in the Main Menu, and other flashs will be slower",
                "flashingMenu"),
            new Checkbox(
                "Camera Zoom on Beat",
                "If unchecked, will disable camera zooming every 4 beats",
                "camZoomOnBeat"),
        ];
        super.create();
    }
}