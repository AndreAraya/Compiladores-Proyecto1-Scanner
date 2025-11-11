import java_cup.runtime.Symbol;
import java_cup.runtime.Scanner;

public class Adaptador implements Scanner {
    private final Lexer lexer;

    public Adaptador(Lexer lexer) {
        this.lexer = lexer;
    }

    @Override
    public Symbol next_token() throws Exception {
        Token t = lexer.yylex(); // tu lexer devuelve Token
        if (t == null) {
            return new Symbol(Sym.EOF);
        }

        int sym = map(t.type);
        Object val = (t.value != null) ? t.value : t.lexeme;
        return new Symbol(sym, t.line + 1, t.column + 1, val);
    }

    private int map(TokenType tt) {
        switch (tt) {
            // === Literales e identificadores ===
            case IDENTIFIER:      return Sym.IDENTIFIER;
            case NUMBER:          return Sym.NUMBER;
            case REAL_NUMBER:     return Sym.REAL_NUMBER;
            case HEX_NUMBER:      return Sym.HEX_NUMBER;
            case BIN_NUMBER:      return Sym.BIN_NUMBER;
            case OCTAL_NUMBER:    return Sym.OCTAL_NUMBER;
            case STRING_LITERAL:  return Sym.STRING_LITERAL;
            case CHAR_LITERAL:    return Sym.CHAR_LITERAL;

            // === Operadores ===
            case PLUS:            return Sym.PLUS;
            case MINUS:           return Sym.MINUS;
            case STAR:            return Sym.STAR;
            case SLASH:           return Sym.SLASH;
            case POWER:           return Sym.POWER;
            case ASSIGN:          return Sym.ASSIGN;
            case LT:              return Sym.LT;
            case GT:              return Sym.GT;
            case LE:              return Sym.LE;
            case GE:              return Sym.GE;
            case NE:              return Sym.NE;
            case COMMA:           return Sym.COMMA;
            case SEMICOLON:       return Sym.SEMICOLON;
            case COLON:           return Sym.COLON;
            case LPAREN:          return Sym.LPAREN;
            case RPAREN:          return Sym.RPAREN;

            // === Palabras clave ===
            case IF:              return Sym.IF;
            case THEN:            return Sym.THEN;
            case ELSE:            return Sym.ELSE;
            case END:             return Sym.END;
            case DO:              return Sym.DO;
            case BEGIN:           return Sym.BEGIN;
            case WHILE:           return Sym.WHILE;
            case FOR:             return Sym.FOR;
            case TO:              return Sym.TO;
            case VAR:             return Sym.VAR;
            case FUNCTION:        return Sym.FUNCTION;
            case PROCEDURE:       return Sym.PROCEDURE;

            // === Tipos de datos ===
            case STRING_KEYWORD:  return Sym.STRING_KEYWORD;
            case INT_KEYWORD:     return Sym.INT_KEYWORD;
            case REAL_KEYWORD:    return Sym.REAL_KEYWORD;
            case CHAR_KEYWORD:    return Sym.CHAR_KEYWORD;

            // === Fin y errores ===
            case EOF:             return Sym.EOF;
            case ERROR:
            default:              return Sym.error;
        }
    }
}

