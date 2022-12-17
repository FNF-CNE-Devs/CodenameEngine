package funkin.system;

import flixel.util.FlxColor;
import flixel.text.FlxText;

class MarkdownUtil {
    public static function applyMarkdownText(text:FlxText, str:String) {
        text.textField.htmlText = Markdown.markdownToHtml(prepareMarkdown(str));
        var changes:Array<FlxTextFormatMarkerPair> = [
            createSizedMarkerPair("{title}", 0xFFFFFFFF, text.size * 2, false, true, true),
            createSizedMarkerPair("{subtitle}", 0xFFFFFFFF, text.size * 1.5, false, true, true),
            createSizedMarkerPair("{subsubtitle}", 0xFFFFFFFF, text.size * 1.25, false, true, true),
            new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFFFF00, false, true), "{o}"),
            new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFF0000, false, true), "{r}"),
            new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF00FF08, false, true), "{g}"),
            new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF7D7D7D, false, true), "{gray}"),
            new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFFFFFF, false, true, 0xFF222222), "{italic}"),
            new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFFFFFF, false, true, 0xFF666666), "{bold}"),
            new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFFFFFF, false, true, 0xFF888888), "{bold-italic}"),
        ];

        // BIG TEXT
        text.applyMarkup(
            parseWarnings(text.textField.text),
            changes
        );
    }

    public static function createSizedMarkerPair(marker:String, color:FlxColor, size:Float, bold:Bool = false, italic:Bool = false, ?underline:Bool = false) {
        @:privateAccess {
            var format = new FlxTextFormat(color, bold, italic);
            format.format.size = Std.int(size);
            format.format.underline = underline;
            return new FlxTextFormatMarkerPair(format, marker);
        }
    }

    public static function parseWarnings(text:String) {
        text = parseEmote(text, "⚠", "{o}(!)", "{o}");
        text = parseEmote(text, "❌", "{r}(X)", "{r}");
        text = parseEmote(text, "✔", "{g}(+)", "{g}");
        return text;
    }

    public static function prepareMarkdown(text:String) {
        text = "\n" + text;
        text = parseEmote(text, "\n> ", "\n{gray}", "{gray}");
        text = parseEmote(text, "\n### ", "\n{subsubtitle}", "{subsubtitle}");
        text = parseEmote(text, "\n## ", "\n{subtitle}", "{subtitle}");
        text = parseEmote(text, "\n# ", "\n{title}", "{title}");
        text = parseEmote(text, "***", "{bold-italic}", "{bold-italic}", "***");
        text = parseEmote(text, "**", "{bold}", "{bold}", "**");
        text = parseEmote(text, "*", "{italic}", "{italic}", "*");
        text = parseEmote(text, "_", "{italic}", "{italic}", "*");
        text = parseEmote(text, "__", "{bold}", "{bold}", "*");
        text.substr("\n".length);
        return text;
    }

    public static function parseEmote(text:String, emote:String, beginning:String, end:String, emoteEnd:String = "\n") {
        var index:Int;
        while((index = text.indexOf(emote)) >= 0) {
            var nextIndex = text.indexOf(emoteEnd, index + emote.length);
            if (nextIndex < 0)
                nextIndex = text.length;
            text = text.substr(0, index) + beginning + text.substring(index + emote.length, nextIndex) + end + (emote == emoteEnd ? "" : emoteEnd) + text.substring(nextIndex + emoteEnd.length);
        }
        return text;
    }
}