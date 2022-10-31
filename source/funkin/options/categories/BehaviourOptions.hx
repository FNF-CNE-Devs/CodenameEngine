package funkin.options.categories;

class BehaviourOptions extends OptionsScreen {
    public override function create() {
        options = [
            new Checkbox("Naughtyness", "naughtyness"),
            new Checkbox("Flashing Menu", "flashingMenu"),
            new Checkbox("Camera Zoom on Beat", "camZoomOnBeat"),
        ];
        super.create();
    }
}