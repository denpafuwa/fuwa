package fuwa;

enum FuwaStmt {
    SScene(sceneName:String, body:Array<FuwaStmt>);
	SChoice(text:String, body:Array<FuwaStmt>);
	SIf(variable:String, value:Dynamic, body:Array<FuwaStmt>);
    SLine(?name:String, text:String);
    SSet(varName:String, value:Dynamic);
    SGoto(sceneName:String);
	SFunc(name:String, args:Array<Dynamic>);
	SComment(text:String);
	SPrev;
    SEnd;
}