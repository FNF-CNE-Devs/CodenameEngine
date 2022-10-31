package funkin.options.categories;

class SaveDataOptions extends OptionsScreen {
    public override function create() {
        options = [
            new TextOption("Reset Save Data", function() {

            })
        ];
        super.create();
    }
}