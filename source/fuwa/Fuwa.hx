package fuwa;

import fuwa.FuwaStmt;
import haxe.Timer;

typedef FuwaBlock =
{
	var name:String;
	var body:Array<FuwaStmt>;
}

typedef FuwaChoice =
{
	var label:String;
	var event:FuwaEvent;
}

typedef FuwaParent =
{
	var type:String;
	var idx:Int;
	var body:Array<FuwaStmt>;
}

typedef FuwaEvent =
{
	var name:String;
	var body:Array<Dynamic>;
	var ?choices:Array<FuwaChoice>;
}

class Fuwa {

	public static var vars:Map<String, Dynamic> = [];
	public static var funcs:Map<String, (Array<Dynamic>) -> Void> = [
		"test" => function(args:Array<Dynamic>) {
			trace("Test func", args);
		}
	];

    var statements:Array<FuwaStmt> = [];
    public var stages:Map<String, Array<FuwaStmt>> = [];
	public var blocks:Array<FuwaBlock> = [];

	var parentBlock:FuwaParent;
    public var curStage:Array<FuwaStmt> = [];
	public var curBlock:Array<FuwaStmt> = [];
	public var idx:Int;
    public var curStmt:FuwaStmt;

	public function new(source:String, startingStage:String)
	{
		idx = 0;
        var tokens = FuwaLexer.tokenize(source);
		statements = FuwaParser.parse(tokens); 
		initStages();
		setStage(startingStage);
	}

	public function progress()
	{
		if (!isAtEnd())
		{
			idx++;
			curStmt = curBlock[idx];
		}
	}

	public function setStage(name:String)
	{
		setCurBlock(stages.get(name));
		idx = 0;
		curStmt = curBlock[idx];
		parentArr = [];
		parentArr.unshift({
			type: 'scene',
			body: curBlock,
			idx: 0
		});
		return curBlock;
	}

	var nestLevel:Int = 0;
	var parentArr:Array<FuwaParent> = [];

	function initStages()
	{
		for (st in statements)
		{
			if (st != null && st.getName() == 'SScene')
			{
				stages.set(st.getParameters()[0], st.getParameters()[1]);
			}
		}
	}

	function addEnds()
	{
		for (b in blocks)
		{
			if (b.body[b.body.length - 1] != SEnd)
			{
				b.body.push(SEnd);
			}
		}
	}

	function removeComments() {}

	function getStmtName(st:FuwaStmt)
	{
		if (st == null)
			return 'null';
		return switch (st.getName())
		{
			case 'SScene':
				return 'scene';
			case 'SLine':
				return 'line';
			case 'SChoice':
				return 'choice';
			case 'SEnd':
				return 'end';
			case 'SGoto':
				return 'goto';
			case 'SSet':
				return 'set';
			case _:
				return 'null';
		}
	}

	public var choices:Array<FuwaChoice> = [];

	function getAllChoices()
	{
		var array:Array<FuwaChoice> = [];

		var choice:FuwaChoice = {
			label: curStmt.getParameters()[0],
			event: {
				name: 'selection',
				body: curStmt.getParameters()[1]
			}
		};
		array.push(choice);
		while (next() != null && next().getName() == 'SChoice')
		{
			idx++;
			curStmt = curBlock[idx];
			array.push({
				label: curStmt.getParameters()[0],
				event: {
					name: 'selection',
					body: curStmt.getParameters()[1]
				}
			});
		}
		return array;
	}

	public function selectChoice(index:Int)
	{
		var selChoice = choices[index];
		parentArr.unshift({
			type: 'choice',
			idx: idx,
			body: cast selChoice.event.body
		});
		setCurBlock(cast selChoice.event.body);
		idx = 0;
		curStmt = curBlock[idx];
		if (curBlock[idx].getName() == 'SPrev')
		{
			run(); // stupid fix
		}
	}

	function setCurBlock(block:Array<FuwaStmt>)
	{
		curBlock = block;
		for (i in 0...curBlock.copy().length)
		{
			if (curBlock[i] == null || curBlock[i].getName() == 'SComment')
			{
				curBlock.remove(curBlock[i]);
			}
		}
	}

	public function run(?ignoreChoices:Bool = false):FuwaEvent
	{
		if (idx < curBlock.length - 1)
			curStmt = curBlock[idx];
		if (curStmt == null)
		{
			return null;
		}
		var ret:FuwaEvent = null;

		if (curStmt.getName() == 'SLine')
		{
			ret = {
				name: 'line',
				body: curStmt.getParameters()
			}
		}
		else if (curStmt.getName() == 'SFunc') {
			ret = {
				name: curStmt.getParameters()[0],
				body: curStmt.getParameters()[1]
			}
		}
		else if (curStmt.getName() == 'SChoice' && idx == 0)
		{
			if (!ignoreChoices)
			{
				var choicesArr = getAllChoices();
				choices = choicesArr;
				ret = {
					name: 'choice',
					body: choices
				};
			}
			else
			{
				ret = {
					name: 'choice',
					body: []
				}
			}
		}
		else if (curStmt.getName() == 'SEnd')
		{
			atEnd = true;
			ret = {
				name: 'end',
				body: []
			}
		}
		else if (curStmt.getName() == 'SPrev')
		{
			parentArr.shift();
			var parent = parentArr.shift();
			setCurBlock(parent.body);
			idx = parent.idx;
			ret = {
				name: getStmtName(curStmt),
				body: [curStmt.getParameters()]
			};
			curStmt = curBlock[idx];
		}
		else if (curStmt.getName() == 'SGoto')
		{
			setCurBlock(setStage(curStmt.getParameters()[0]));
			ret = {
				name: 'goto',
				body: curStmt.getParameters()[0]
			};

			parentArr = [];
			idx = -1;
		}
		else if (curStmt.getName() == 'SSet')
		{
			ret = {
				name: 'set',
				body: curStmt.getParameters()
			}
			Fuwa.vars.set(curStmt.getParameters()[0], curStmt.getParameters()[1]);
		}
		if (ret != null)
		{
			ret.choices = [];
		}
		if (ret != null && curStmt.getName() != 'SChoice' && next() != null && next().getName() == 'SChoice')
		{
			idx++;
			curStmt = curBlock[idx];
			var allChoices = cast getAllChoices();
			choices = allChoices;
			ret.choices = allChoices;
		}

		return ret;
	}

	var atEnd:Bool = false;

	public function isAtEnd()
	{
		return atEnd;
	}

	public function next()
	{
		return (idx + 1) <= (curBlock.length - 1) ? curBlock[idx + 1] : null;
	}
}