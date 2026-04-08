package fuwa;

enum FuwaTokenType {
    KW_SCENE;
    KW_SET;
    KW_GOTO;
    KW_END;

    TK_IDENTIFIER;
    TK_COLON;
    TK_LBRACE;
    TK_RBRACE;
    TK_STRING;
    TK_NUMBER;
    TK_BOOLEAN;
    TK_NEWLINE;
    TK_EOF;
    TK_WHITESPACE;
}

typedef FuwaToken = {
    var type:FuwaTokenType;
    var value:Dynamic;
}