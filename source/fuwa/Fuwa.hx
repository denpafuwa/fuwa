package fuwa;

class Fuwa {

    var statements:Array<FuwaStmt> = [];
    public var scenes:Map<String, Array<FuwaStmt>> = [];

    public var curScene:Array<FuwaStmt> = [];
    public var idx:Int;
    public var curStmt:FuwaStmt;

    public function new(source:String, ?startingScene:Null<String>) {
        var tokens = FuwaLexer.tokenize(source);
        statements = FuwaParser.parse(tokens);
        for (scene in statements) {
            // make sure its actually a scene
            if (scene.getName() == 'SScene') {
                var args = scene.getParameters();
                scenes.set(args[0], args[1]);
            }
        }   

        if (startingScene != null)
            setScene(startingScene);
    }

    public function setScene(name:String) {
        curScene = scenes.get(name);
        idx = 0;
        curStmt = curScene[idx];
    }
}