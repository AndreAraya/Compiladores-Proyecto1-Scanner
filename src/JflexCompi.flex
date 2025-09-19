import java.util.Locale;
import java.util.HashMap;

%%

// Opciones de JFlex
%class Lexer
%unicode
%line
%column
%public
%type Token

%state COMMENT
%state COMMENT_CURLY_BRACE
%state COMMENT_PAREN_STAR

%{
private static final HashMap<String, TokenType> keywords;

static {
    keywords = new HashMap<>();
    keywords.put("absolute", TokenType.ABSOLUTE);
    keywords.put("and", TokenType.AND);
    keywords.put("array", TokenType.ARRAY);
    keywords.put("asm", TokenType.ASM);
    keywords.put("begin", TokenType.BEGIN);
    keywords.put("case", TokenType.CASE);
    keywords.put("const", TokenType.CONST);
    keywords.put("constructor", TokenType.CONSTRUCTOR);
    keywords.put("destructor", TokenType.DESTRUCTOR);
    keywords.put("external", TokenType.EXTERNAL);
    keywords.put("div", TokenType.DIV);
    keywords.put("do", TokenType.DO);
    keywords.put("downto", TokenType.DOWNTO);
    keywords.put("else", TokenType.ELSE);
    keywords.put("end", TokenType.END);
    keywords.put("file", TokenType.FILE);
    keywords.put("for", TokenType.FOR);
    keywords.put("forward", TokenType.FORWARD);
    keywords.put("function", TokenType.FUNCTION);
    keywords.put("goto", TokenType.GOTO);
    keywords.put("if", TokenType.IF);
    keywords.put("implementation", TokenType.IMPLEMENTATION);
    keywords.put("in", TokenType.IN);
    keywords.put("inline", TokenType.INLINE);
    keywords.put("interface", TokenType.INTERFACE);
    keywords.put("interrupt", TokenType.INTERRUPT);
    keywords.put("label", TokenType.LABEL);
    keywords.put("mod", TokenType.MOD);
    keywords.put("nil", TokenType.NIL);
    keywords.put("not", TokenType.NOT);
    keywords.put("object", TokenType.OBJECT);
    keywords.put("of", TokenType.OF);
    keywords.put("or", TokenType.OR);
    keywords.put("packed", TokenType.PACKED);
    keywords.put("private", TokenType.PRIVATE);
    keywords.put("procedure", TokenType.PROCEDURE);
    keywords.put("record", TokenType.RECORD);
    keywords.put("repeat", TokenType.REPEAT);
    keywords.put("set", TokenType.SET);
    keywords.put("shl", TokenType.SHL);
    keywords.put("shr", TokenType.SHR);
    keywords.put("string", TokenType.STRING_KEYWORD);
    keywords.put("then", TokenType.THEN);
    keywords.put("to", TokenType.TO);
    keywords.put("type", TokenType.TYPE);
    keywords.put("unit", TokenType.UNIT);
    keywords.put("until", TokenType.UNTIL);
    keywords.put("uses", TokenType.USES);
    keywords.put("var", TokenType.VAR);
    keywords.put("virtual", TokenType.VIRTUAL);
    keywords.put("while", TokenType.WHILE);
    keywords.put("with", TokenType.WITH);
    keywords.put("xor", TokenType.XOR);
}

// Métodos auxiliares para crear tokens
private Token token(TokenType type) {
    return new Token(type, yytext(), yyline, yycolumn);
}

private Token token(TokenType type, Object value) {
    return new Token(type, yytext(), yyline, yycolumn, value);
}

// Secuencias de escape
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
%}

// Macros
Newline = \r|\n|\r\n
Whitespace = [ \t]+ | {Newline}
Letter = [a-zA-Z]
DecimalDigit = [0-9]
HexDigit = [0-9a-fA-F]
BinDigit = [01]
Identifier = {Letter} ({Letter}|{DecimalDigit}|_)*

Exponent = [eE][+-]?{DecimalDigit}+
RealNum_DecimalPart = {DecimalDigit}+ "." {DecimalDigit}+

EscapeSeq = "\\\\" | "\\n" | "\\r" | "\\t" | "\\'" | "\\\""

CharContent = [^'\r\n\\] | {EscapeSeq}
StringContent = [^\\\"\r\n] | {EscapeSeq}

%%

// Estado inicial
<YYINITIAL> {
    {Whitespace}+              { /* ignorar */ }
    "//".*{Newline}            { /* comentario */ }
    "/*"                        { yybegin(COMMENT); }
    "{"                         { yybegin(COMMENT_CURLY_BRACE); }
    "(*"                        { yybegin(COMMENT_PAREN_STAR); }

    // Operadores
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
    "="         { return token(TokenType.ASSIGN); }
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

    // Literales numéricas
    "$"{HexDigit}+        { return token(TokenType.HEX_NUMBER, Long.parseLong(yytext().substring(1),16)); }
    "%"{BinDigit}+        { return token(TokenType.BIN_NUMBER, Long.parseLong(yytext().substring(1),2)); }
    "&"{DecimalDigit}[0-7]* { return token(TokenType.OCTAL_NUMBER, Long.parseLong(yytext().substring(1),8)); }
    {RealNum_DecimalPart}({Exponent})? { return token(TokenType.REAL_NUMBER, Double.parseDouble(yytext())); }
    {DecimalDigit}+{Exponent}          { return token(TokenType.REAL_NUMBER, Double.parseDouble(yytext())); }
    {DecimalDigit}+                     { return token(TokenType.NUMBER, Integer.parseInt(yytext())); }

    // Identificadores y palabras reservadas
    {Identifier} {
        String lexeme = yytext();
        TokenType type = keywords.get(lexeme.toLowerCase(Locale.ROOT));
        if (type != null) return token(type);
        return token(TokenType.IDENTIFIER, lexeme);
    }

    // Literales de caracteres
    "'" {CharContent} "'" {
        String content = processEscapes(yytext().substring(1, yytext().length()-1));
        if (content.length() != 1) return token(TokenType.ERROR);
        return token(TokenType.CHAR_LITERAL, content.charAt(0));
    }

    // Literales de strings
    "\"" {StringContent}* "\"" {
        String content = processEscapes(yytext().substring(1, yytext().length()-1));
        return token(TokenType.STRING_LITERAL, content);
    }

    // Error
    . { return token(TokenType.ERROR); }
}

// Estados de comentarios
<COMMENT> {
    "*/" { yybegin(YYINITIAL); }
    [^] { /* ignorar */ }
}

<COMMENT_CURLY_BRACE> {
    "}" { yybegin(YYINITIAL); }
    [^] { /* ignorar */ }
}

<COMMENT_PAREN_STAR> {
    "*)" { yybegin(YYINITIAL); }
    [^] { /* ignorar */ }
}

