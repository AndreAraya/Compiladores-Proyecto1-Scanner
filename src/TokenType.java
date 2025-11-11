public enum TokenType {
    // Palabras reservadas (case-insensitive)
    ABSOLUTE, AND, ARRAY, ASM, BEGIN, CASE, CONST, CONSTRUCTOR, DESTRUCTOR,
    EXTERNAL, DIV, DO, DOWNTO, ELSE, END, FILE, FOR, FORWARD, FUNCTION, GOTO,
    IF, IMPLEMENTATION, IN, INLINE, INTERFACE, INTERRUPT, LABEL, MOD, NIL,
    NOT, OBJECT, OF, OR, PACKED, PRIVATE, PROCEDURE, RECORD, REPEAT, SET, SHL,
    SHR, STRING_KEYWORD, INT_KEYWORD, REAL_KEYWORD, CHAR_KEYWORD, THEN, TO, TYPE, UNIT, UNTIL, USES, VAR, VIRTUAL, WHILE,
    WITH, XOR,

    // Literales
    NUMBER,         // Enteros decimales (del .flex)
    REAL_NUMBER,    // Números reales con exponente o decimales
    HEX_NUMBER,     // Números hexadecimales ($FF, $1A3)
    BIN_NUMBER,     // Números binarios (%1010)
    OCTAL_NUMBER,   // Números octales (&123)
    STRING_LITERAL, // Literales de cadena "..."
    CHAR_LITERAL,   // Literales de caracter 'A'

    // Identificadores
    IDENTIFIER,

    // Operadores y delimitadores
    POWER, NE, LE, GE, INCREMENT, DECREMENT,
    PLUS, MINUS, STAR, SLASH, ASSIGN,
    LT, GT, COMMA, SEMICOLON, LPAREN, RPAREN,
    LBRACKET, RBRACKET, COLON, DOT, CARET,

    // Tokens especiales
    EOF, ERROR
}
