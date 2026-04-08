package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import fuwa.FuwaLexer;
import fuwa.FuwaParser;
import haxe.Json;
import openfl.Assets;

// import openfl.filesystem.File;
#if neko
import openfl.filesystem.File;
#end

class PlayState extends FlxState
{

	var text:FlxText;
	var choices:FlxTypedSpriteGroup<FlxButton>;

	override public function create()
	{
		var tokens = FuwaLexer.tokenize(Assets.getText("assets/data/test.fuwa"));
		var statements = FuwaParser.parse(tokens);
		for (st in statements) {
			trace (st);
		}
		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
