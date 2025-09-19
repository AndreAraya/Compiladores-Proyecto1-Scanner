public final class Token {
    public final TokenType type;
    public final String lexeme;
    public final int line;
    public final int column;
    public final Object value; // Se añadirá un valor si el token tiene uno asociado

    // Constructor para tokens que no tienen valor asociado (como operadores)
    public Token(TokenType type, String lexeme, int line, int column) {
        this(type, lexeme, line, column, null);
    }

    // Constructor para tokens con un valor asociado (como números, identificadores, etc.)
    public Token(TokenType type, String lexeme, int line, int column, Object value) {
        this.type = type;
        this.lexeme = lexeme;
        this.line = line;
        this.column = column;
        this.value = value;
    }

    @Override
    public String toString() {
        // Si el token tiene valor, lo mostramos en el toString
        if (value != null) {
            return String.format("%s «%s» @%d:%d => %s", type, lexeme, line, column, value);
        }
        return String.format("%s «%s» @%d:%d", type, lexeme, line, column);
    }
}

