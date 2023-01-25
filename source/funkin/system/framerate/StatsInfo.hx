package funkin.system.framerate;

#if (gl_stats && !disable_cffi && (!html5 || !canvas))
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;

class StatsInfo extends FramerateCategory {
    public function new() {
        super("Asset Libraries Tree Info");
    }

    public override function __enterFrame(t:Int) {
        var text = "totalDC: " + Context3DStats.totalDrawCalls();
        text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
        text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
        
        this.text.text = text;
        super.__enterFrame(t);
    }
}
#end