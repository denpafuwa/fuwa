package fuwa;

import fuwa.FuwaStmt;

class FuwaParser {
    public static var pos:Int = 0;
    public static var tokens:Array<FuwaToken> = [];
    public static var statements:Array<FuwaStmt> = [];

	public static function parse(Tokens:Array<FuwaToken>)
	{
        tokens = Tokens;
        var rawStatements:Array<FuwaStmt> = [];
        while (!isAtEnd()) {
            rawStatements.push(getStatement());
            advance();
            eatNewlines();
        }
        return rawStatements;
    }

    static function getStatement():Null<FuwaStmt> {
        return switch (current().type) {
            case KW_GOTO:
                if (peek(1) != null && peek(1).type == TK_STRING) {
                    advance();
                    return SGoto(current().value);
                }
                return null;
            case KW_END:
                return SEnd;
            case KW_SET:
                if (peek(1) != null && peek(1).type == TK_IDENTIFIER) {
                    advance();
                    var name = current().value;
                    if (peek(1) != null) {
                        advance();
                        switch (current().type) {
                            case TK_NUMBER, TK_STRING, TK_BOOLEAN, TK_IDENTIFIER:
                                return SSet(name, current().value);
                            case _:
                                return null;
                        }
                        return null;
                    }
                    return null;
                }
                return null;
            case KW_SCENE:
                if (peek(1) != null && peek(1).type == TK_STRING) {
                    advance();
					var sceneName = current().value;
                    if (peek(1) != null && peek(1).type == TK_LBRACE) {
						var body:Array<FuwaStmt> = [];
                        advance(); 
                        eatNewlines();
                        advance();
                        while (current() != null && current().type != TK_RBRACE && current().type != TK_EOF) {
                            eatNewlines();
							var x = getStatement();
                            advance();
                            eatNewlines();
                            body.push(x);
                        }
                        return SScene(sceneName, body);
                    }
                    return null;
                }
                return null;
			case KW_CHOICE:
				if (peek(1) != null && peek(1).type == TK_STRING)
				{
					advance();
					var text = current().value;
					if (peek(1) != null && peek(1).type == TK_LBRACE)
					{
						var body:Array<FuwaStmt> = [];
						advance();
						eatNewlines();
						advance();
						while (current() != null && current().type != TK_RBRACE && current().type != TK_EOF)
						{
							eatNewlines();
							var x = getStatement();
							advance();
							eatNewlines();
							body.push(x);
						}
						return SChoice(text, body);
					}
					return null;
				}
				return null;
            case TK_STRING:
                    var line = SLine(null, current().value);
                    return line;
            case TK_IDENTIFIER:
                if (peek(1) != null && peek(1).type == TK_COLON) {
					var name = current().value;
                    advance();
                    if (peek(1) != null && peek(1).type == TK_STRING) {
                        advance();
                        var text = current().value;
                        return SLine(name, text);
                    }
                    return null;
                }
                return null;
            case _:
                null;
        }
        return null;
    }

    static function eatNewlines() {
        while (current() != null && current().type == TK_NEWLINE) advance();
    }

    static function isAtEnd() {
        return pos >= tokens.length;
    }

    static function current() {
        return tokens[pos];
    }

    static function advance() {
        if (pos <= tokens.length - 1) {
            pos++;
        }
    }

    static function peek(by:Int) {
        return ((pos + by) < (tokens.length)) ? tokens[pos + by] : null;
    }
}