package funkin.editors.charter;

import flixel.util.FlxColor;
import funkin.backend.system.Conductor;
import openfl.geom.Rectangle;
import openfl.media.Sound;
import flixel.system.FlxSound;
import lime.media.AudioBuffer;
import flixel.FlxSprite;

class CharterWaveForms extends FlxTypedGroup<WaveformSprite> {
	public var sound:FlxSound;
	public var strumLineID:Int = 0;

	public function new(sound:FlxSound) {
		this.sound = sound;
		super();

		for (measure in 0...Std.int(Conductor.getMeasuresLength())) {
			var waveFormMeasure:WaveformSprite = new WaveformSprite(0, (40 * Conductor.getMeasureLength()) * measure, sound, 40 * 4, Std.int(40 * Conductor.getMeasureLength()));
			waveFormMeasure.generateFlixel(
				Conductor.getTimeForStep(measure * Conductor.getMeasureLength()),
				Conductor.getTimeForStep((measure+1) * Conductor.getMeasureLength())
			);
			trace(
				Conductor.getTimeForStep(measure * Conductor.getMeasureLength()),
				Conductor.getTimeForStep((measure+1) * Conductor.getMeasureLength())
			);
			add(waveFormMeasure);
			
		}
	}

	public override function update(elapsed:Float) {
		for (mem in members) mem.x = strumLineID * 40 * 4;
		super.update(elapsed);
	}
}

class WaveformSprite extends FlxSprite {
    public var buffer:AudioBuffer;
    public var sound:Sound;
    public var peak:Float = 0;
    public var valid:Bool = true;

    public override function destroy() {
        super.destroy();
        if (buffer != null) {
            buffer.data.buffer = null;
            buffer.dispose();
        }
    }
    public function new(x:Float, y:Float, buffer:Dynamic, w:Int, h:Int) {
        super(x,y);
        this.buffer = null;
        if (Std.isOfType(buffer, FlxSound)) {
            @:privateAccess
            this.buffer = cast(buffer, FlxSound)._sound.__buffer;
            @:privateAccess
            this.sound = cast(buffer, FlxSound)._sound;
        } else if (Std.isOfType(buffer, Sound)) {
            @:privateAccess
            this.buffer = cast(buffer, Sound).__buffer;
            this.sound = cast(buffer, Sound);
        } else if (Std.isOfType(buffer, AudioBuffer)) {
            @:privateAccess
            this.buffer = cast(buffer, AudioBuffer);
        } else {
            valid = false;
            return;
        }
		peak = Math.pow(2, buffer.bitsPerSample-1)-1; // max positive value of a bitsPerSample bits integer
        makeGraphic(w, h, FlxColor.WHITE); // transparent
    }

    public function generate(startPos:Int, endPos:Int) {
        if (!valid) return;
        startPos -= startPos % buffer.bitsPerSample;
        endPos -= endPos % buffer.bitsPerSample;
        pixels.lock();
        pixels.fillRect(new Rectangle(0, 0, pixels.width, pixels.height), 0); 
        var diff = endPos - startPos;
        var diffRange = Math.floor(diff / pixels.height);
        for(y in 0...pixels.height) {
            var d = Math.floor(diff * (y / pixels.height));
            d -= d % buffer.bitsPerSample;
            var pos = startPos + d;
            var max:Int = 0;
            for(i in 0...Math.floor(diffRange / buffer.bitsPerSample)) {
                var thing = buffer.data.buffer.get(pos + (i * buffer.bitsPerSample)) | (buffer.data.buffer.get(pos + (i * buffer.bitsPerSample) + 1) << 8);
                if (thing > 256 * 128)
                    thing -= 256 * 256;
                if (max < thing) max = thing;
            }
            var thing = max;
            var w = (thing) / pixels.width;
            pixels.fillRect(new Rectangle((pixels.width / 2) - (w / 2), y, w, 1), FlxColor.RED);
        }
        pixels.unlock();
    }

    public function generateFlixel(startPos:Float, endPos:Float) {
        if (!valid) return;
        var rateFrequency = (1 / buffer.sampleRate);
        var multiplicator = 1 / rateFrequency; // 1 hz/s
        multiplicator *= buffer.bitsPerSample;
        multiplicator -= multiplicator % buffer.bitsPerSample;

        generate(Math.floor(startPos * multiplicator / 4000 / buffer.bitsPerSample) * buffer.bitsPerSample, Math.floor(endPos * multiplicator / 4000 / buffer.bitsPerSample) * buffer.bitsPerSample);
    }
}