package funkin.options;

class OptionsTree extends FlxTypedGroup<OptionsScreen> {
    public override function new() {
        super();

    }

    public override function update(elapsed:Float) {
        var last = members.last();
        if (last != null)
            last.update(elapsed);
    }

    public override function add(m:OptionsScreen) {
        super.add(m);
        setup(m);
        onMenuChange();
        return m;
    }
    public override function insert(pos:Int, m:OptionsScreen) {
        var last = members.last();
        super.insert(pos, m);
        setup(m);
        if (last != members.last())
            onMenuChange();
        return m;
    }

    public function setup(m:OptionsScreen) {
        m.onClose = __subMenuClose;
        m.id = members.indexOf(m);
        m.parent = this;
    }

    function __subMenuClose(m:OptionsScreen) {
        remove(m, true);
        onMenuChange();
        onMenuClose(m);
    }

    public dynamic function onMenuChange() {

    }

    public dynamic function onMenuClose(m:OptionsScreen) {
    }
}