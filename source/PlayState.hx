package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import fuwa.Fuwa;
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
	var choices:FlxTypedSpriteGroup<FlxText>;
	var varText:FlxText;
	var fuwa:Fuwa;
	var curDialogue:FuwaEvent;

	public function new()
	{
		super();
		fuwa = new Fuwa(Assets.getText("assets/data/test.fuwa"), "Coffee Shop");
		Fuwa.vars.clear();
	}

	override public function create()
	{
		for (k => v in fuwa.scenes)
		{
			trace(k);
		}

		@:privateAccess
		trace(fuwa.parentArr);
		curDialogue = fuwa.run();
		trace(curDialogue);
		text = new FlxText(20, 20, FlxG.width - 40, dialogueText(curDialogue), 32);
		add(text);
		choices = new FlxTypedSpriteGroup<FlxText>(20, 120);
		add(choices);
		varText = new FlxText(20, FlxG.height - 100, 0, "Value of test_variable: Unassigned :(", 32);
		add(varText);
		super.create();
	}

	function dialogueText(dlg:FuwaEvent)
	{
		if (dlg.body[0] != null)
		{
			return '${dlg.body[0]} "${dlg.body[1]}"';
		}
		return '${dlg.body[1]}';
	}

	var inChoice:Bool = false;
	var choiceMap:Map<FlxText, Int> = [];	
	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.R)
			FlxG.switchState(PlayState.new);
		inChoice = curDialogue != null && curDialogue.choices.length > 0;

		if (FlxG.keys.justPressed.ENTER)
		{
			if (!inChoice && curDialogue != null && curDialogue.name == 'line' && !fuwa.isAtEnd() && fuwa.idx <= fuwa.curBlock.length)
			{
				fuwa.progress();
				doDialogue();
			}
		}

		if (inChoice && choices.length == 0) {}

		for (c in choices)
		{
			if (FlxG.mouse.overlaps(c) && FlxG.mouse.justPressed)
			{
				fuwa.selectChoice(choiceMap.get(c));
				for (c in choices.members)
				{
					c.kill();
					c.destroy();
				}
				choices.clear();
				choiceMap = [];
				doDialogue();
			}
		}

		varText.text = 'Value of test variable: ' + ((Fuwa.vars.exists('test_variable')) ? Std.string(Fuwa.vars.get('test_variable')) : 'Unassigned :(');

		super.update(elapsed);
	}
	function doDialogue()
	{
		trace(curDialogue);
		curDialogue = fuwa.run();
		if (curDialogue == null)
		{
			return;
		}

		switch (curDialogue.name)
		{
			case 'line':
				text.text = dialogueText(curDialogue);
				for (i in 0...curDialogue.choices.length)
				{
					var text = new FlxText(0, 64 * i, FlxG.width - 40, curDialogue.choices[i].label, 32);
					choices.add(text);
					choiceMap.set(text, i);
				}
			case 'set', 'goto':
				if (curDialogue.name == 'goto' || curDialogue.name == 'set')
				{
					fuwa.progress();
					doDialogue();
				}
			case 'end':
				// end dialogue
		}
	}
}
