import java.util.Locale;
import java.util.HashMap;

%%
%class Lexer
%unicode
%line
%column
%public
%type Token

%state COMMENT
%state COMMENT_CURLY_BRACE
%state COMMENT_PAREN_STAR
%state STRING_UNCLOSED 

%{
private static final int MAX_LINE_LENGTH = 120; 
private int lastCheckedLine = -1;

private static final HashMap<String, TokenType> keywords;

static {
    keywords = new HashMap<>();
    keywords.put("begin", TokenType.BEGIN);
    keywords.put("end", TokenType.END);
    keywords.put("if", TokenType.IF);
    keywords.put("then", TokenType.THEN);
    keywords.put("else", TokenType.ELSE);
    keywords.put("while", TokenType.WHILE);
    keywords.put("do", TokenType.DO);
    keywords.put("var", TokenType.VAR);
    keywords.put("function", TokenType.FUNCTION);
    keywords.put("procedure", TokenType.PROCEDURE);
    keywords.put("string", TokenType.STRING_KEYWORD);
    keywords.put("int", TokenType.INT_KEYWORD);
    keywords.put("real", TokenType.REAL_KEYWORD);
    keywords.put("char", TokenType.CHAR_KEYWORD);
    keywords.put("program",   TokenType.PROGRAM);
    keywords.put("read",      TokenType.READ);
    keywords.put("write",     TokenType.WRITE);
    keywords.put("for",       TokenType.FOR);
    keywords.put("to",        TokenType.TO);
    keywords.put("downto",    TokenType.DOWNTO);
    keywords.put("or",        TokenType.OR);
    keywords.put("and",       TokenType.AND);
    keywords.put("not",       TokenType.NOT);
    keywords.put("div",       TokenType.DIV);
    keywords.put("mod",       TokenType.MOD);

}

// ======= Métodos auxiliares =======
private Token token(TokenType type) {
    return new Token(type, yytext(), yyline, yycolumn);
}
private Token token(TokenType type, Object value) {
    return new Token(type, yytext(), yyline, yycolumn, value);
}

// Manejo de secuencias de escape
private String processEscapes(String text) {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < text.length(); i++) {
        char c = text.charAt(i);
        if (c == '\\' && i + 1 < text.length()) {
            i++;
            switch (text.charAt(i)) {
                case 'n': sb.append('\n'); break;
                case 't': sb.append('\t'); break;
                case 'r': sb.append('\r'); break;
                case '\'': sb.append('\''); break;
                case '"': sb.append('"'); break;
                case '\\': sb.append('\\'); break;
                default: sb.append(text.charAt(i)); break;
            }
        } else {
            sb.append(c);
        }
    }
    return sb.toString();
}

// ======= Verificación de longitud de línea =======
private void checkLineLength() {
    if (yyline != lastCheckedLine) {
        lastCheckedLine = yyline;
        String currentLine = yytext();
        if (currentLine.length() > MAX_LINE_LENGTH) {
            returnError(String.format("Error: línea %d excede el máximo de %d caracteres.",
                    yyline + 1, MAX_LINE_LENGTH));
        }
    }
}

private void returnError(String msg) {
    System.err.println(msg);
}
%}

Newline = \r|\n|\r\n
Whitespace = [ \t]+ | {Newline}
Letter = [a-zA-Z]
DecimalDigit = [0-9]
Identifier = {Letter}({Letter}|{DecimalDigit}|_)*

EscapeSeq = "\\\\" | "\\n" | "\\r" | "\\t" | "\\'" | "\\\""
CharContent = [^'\r\n\\] | {EscapeSeq}
StringContent = [^\\\"\r\n] | {EscapeSeq}

%%

// ======= Estado inicial =======
<YYINITIAL> {
    {Whitespace}+                { checkLineLength(); }
    "//".*{Newline}              { checkLineLength(); }
    "/*"                         { yybegin(COMMENT); }
    "{"                          { yybegin(COMMENT_CURLY_BRACE); }
    "(*"                         { yybegin(COMMENT_PAREN_STAR); }

    // ==== Operadores ====
    "**"        { return token(TokenType.POWER); }
    "<>"        { return token(TokenType.NE); }
    "<="        { return token(TokenType.LE); }
    ">="        { return token(TokenType.GE); }
    "++"        { return token(TokenType.INCREMENT); }
    "--"        { return token(TokenType.DECREMENT); }
    "+"         { return token(TokenType.PLUS); }
    "-"         { return token(TokenType.MINUS); }
    "*"         { return token(TokenType.STAR); }
    "/"         { return token(TokenType.SLASH); }
    ":="        { return token(TokenType.ASSIGN); }  
    "="         { return token(TokenType.EQ); }
    "<"         { return token(TokenType.LT); }
    ">"         { return token(TokenType.GT); }
    ","         { return token(TokenType.COMMA); }
    ";"         { return token(TokenType.SEMICOLON); }
    "("         { return token(TokenType.LPAREN); }
    ")"         { return token(TokenType.RPAREN); }
    "["         { return token(TokenType.LBRACKET); }
    "]"         { return token(TokenType.RBRACKET); }
    ":"         { return token(TokenType.COLON); }
    "."         { return token(TokenType.DOT); }
    "^"         { return token(TokenType.CARET); }
    "MOD"       { return token(TokenType.MOD); }
    "OR"        { return token(TokenType.OR); }
    "AND"       { return token(TokenType.AND); }
    "NOT"       { return token(TokenType.NOT); }

    // ==== Literales numéricos ====
    [0-9]+"."[0-9]+([eE][+-]?[0-9]+)?   { return token(TokenType.REAL_NUMBER, Double.parseDouble(yytext())); }
    [0-9]+([eE][+-]?[0-9]+)?            { return token(TokenType.NUMBER, Integer.parseInt(yytext())); }

    // ==== Identificadores / Palabras clave ====
    {Identifier} {
        String lexeme = yytext();
        TokenType type = keywords.get(lexeme.toLowerCase(Locale.ROOT));
        if (type != null) return token(type);
        System.err.println("Token nulo o desconocido encontrado en línea " + yyline + ": " + lexeme);
        return token(TokenType.IDENTIFIER, lexeme);
    }

    // ==== Literales de caracteres ====
    "'" {CharContent} "'" {
        String content = processEscapes(yytext().substring(1, yytext().length()-1));
        if (content.length() != 1) return token(TokenType.ERROR);
        return token(TokenType.CHAR_LITERAL, content.charAt(0));
    }

    // ==== Literales de strings cerrados ====
    "\"" {StringContent}* "\"" {
        String content = processEscapes(yytext().substring(1, yytext().length()-1));
        return token(TokenType.STRING_LITERAL, content);
    }

    // ==== String sin cerrar ====
    "\"" {StringContent}* {Newline}? {
        System.err.printf("Error: String sin cerrar en línea %d.%n", yyline + 1);
        return token(TokenType.ERROR);
    }

    // ==== Otros errores ====
    . { 
        System.err.printf("Error: token inesperado '%s' en línea %d.%n", yytext(), yyline + 1);
        return token(TokenType.ERROR); 
    }
}

// ======= Estados de comentarios =======
<COMMENT> {
    "*/" { yybegin(YYINITIAL); }
    [^]  { /* ignorar */ }
}

<COMMENT_CURLY_BRACE> {
    "}"  { yybegin(YYINITIAL); }
    [^]  { /* ignorar */ }
}

<COMMENT_PAREN_STAR> {
    "*)" { yybegin(YYINITIAL); }
    [^]  { /* ignorar */ }
}

