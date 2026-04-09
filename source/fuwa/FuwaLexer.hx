package fuwa;

import fuwa.FuwaToken.FuwaTokenType;
import fuwa.FuwaToken;

using StringTools;

class FuwaLexer {
    static var source:String;
    static var pos:Int = 0;
    static var line:Int = 0;
    static var tokens:Array<FuwaToken> = [];

    static final NO_WHITESPACE:Bool = true;

    static final KEYWORDS:Map<String, FuwaTokenType> = [
        'scene' => KW_SCENE,
		'choice' => KW_CHOICE,
        'goto' => KW_GOTO,
        'set' => KW_SET,
		'end' => KW_END,
		'prev' => KW_PREV
    ];

    public static function tokenize(Source:String) {
		pos = 0;
        source = Source;
        var rawTokens:Array<FuwaToken> = [];
        while (!isAtEnd()) {
            rawTokens.push(getToken());
            advance();
        }

        for (tk in rawTokens) {
            if (NO_WHITESPACE) {
                if (tk.type != TK_WHITESPACE) {
                    tokens.push(tk);
                }
            } else {
                tokens = rawTokens;
            }
        }

        token(TK_EOF, '\x00');
        
        return tokens;
    }
    static function getToken() {
        return switch (current()) {
            case ':':
                token(TK_COLON, ':');
            case '{':
                token(TK_LBRACE, '{');
            case '}':
                token(TK_RBRACE, '}');
            case '\n':
				token(TK_NEWLINE, '\n');
            case '"':
                scanString();
			case '/':
				if (peek(1) == '/')
				{
					advance();
					return token(TK_COMMENT, '//');
				}
				throw "Lexer: error parsing '/'";
            case ' ', '\t', '\r':
                token(TK_WHITESPACE, current());
            case _:
                if (isDigit(current())) {
                    return scanNumber();
                } else if (isAlpha(current())) {
                    return scanIdentifier();
                }
				throw "Lexer: unidentified characters";
        }
    }


    static function scanNumber() {
        var str = new StringBuf();
        str.add(current());
		var isFloat = false;
        while ((isDigit(peek(1)) || peek(1) == '.') && !isAtEnd()) {
			if (peek(1) == '.')
				isFloat = true;
            advance();
            str.add(current());
        }

		if (!isFloat)
			return token(TK_INT, Std.parseInt(str.toString()));
		else
			return token(TK_FLOAT, Std.parseFloat(str.toString()));
    }

    static function scanString() {
        var str:StringBuf = new StringBuf();
        advance();
        while ((current() != '"' || source.charAt(pos-1) == '\\' && current() == '"') && !isAtEnd() && current() != '\n') {
            str.add(current());
            advance();
        }

        return token(TK_STRING, replaceEscapeCharacters(str.toString()));
    }

    static function replaceEscapeCharacters(str:String) {
        str = str.replace('\\\"', '"');
        str = str.replace('\\n', '\n');
        return str;
    }

    static function scanIdentifier() {
        var str = new StringBuf();
        while (isAlphanumeric(current())) {
            str.add(current());
            advance();
        }

        var res = str.toString();

        pos--; // shabby fix

        if (res == 'true' || res == 'false') {
            return token(TK_BOOLEAN, res == 'true');
        } else if (KEYWORDS.exists(res)) {
            return token(KEYWORDS.get(res), res);
        }

        return token(TK_IDENTIFIER, res);
    }

    static function isDigit(char:String) {
        return char >= '0' && char <= '9';
    }

    static function isAlpha(char:String) {
        return ((char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z') || char == '_');
    }

    static function isAlphanumeric(char:String) {
        return isDigit(char) || isAlpha(char);
    }

    static function isAtEnd() {
        return pos >= source.length;
    }

    static function current() {
        return source.charAt(pos);
    }

    static function advance() {
        pos++;
    }

    static function peek(by:Int) {
        if (pos + by < source.length)
            return source.charAt(pos + by);
        return null;
    }

    static function token(type:FuwaTokenType, value:Dynamic):FuwaToken {
        return {type: type, value: value}
    }
}