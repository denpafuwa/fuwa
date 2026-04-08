package fuwa;

enum FuwaStmt {
    SScene(sceneName:String, body:Array<FuwaStmt>);
    SLine(?name:String, text:String);
    SSet(varName:String, value:Dynamic);
    SGoto(sceneName:String);
    SEnd;
}