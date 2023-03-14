package funkin.editors;

import funkin.editors.ui.*;

class UIDebugState extends UIState {
    public override function create() {
        super.create();
        add(new UICheckbox(10, 10, "Test unchecked", false));
        add(new UICheckbox(10, 40, "Test checked", true));
    }
}