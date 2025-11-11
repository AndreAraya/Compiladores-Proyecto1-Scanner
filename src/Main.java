import java.io.*;
import java.util.*;
import java_cup.runtime.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // Archivo de entrada
        String inputFile = (args.length > 0) ? args[0] : "sample.txt";
        BufferedReader reader = new BufferedReader(new FileReader(inputFile));
        Lexer lexer = new Lexer(reader);

        // Estructuras para conteo y errores léxicos
        Map<String, Map<Integer, Integer>> tokensMap = new LinkedHashMap<>();
        List<String> erroresLexicos = new ArrayList<>();

        Token t;
        do {
            t = lexer.yylex(); // método JFlex devuelve Token
            if (t == null) break; // fin de archivo

            if (t.type == TokenType.ERROR) {
                erroresLexicos.add(String.format(
                    "Error léxico en línea %d, columna %d: lexema «%s»",
                    t.line + 1, t.column + 1, t.lexeme
                ));
            } else {
                tokensMap.putIfAbsent(t.lexeme, new LinkedHashMap<>());
                Map<Integer, Integer> lineas = tokensMap.get(t.lexeme);
                lineas.put(t.line + 1, lineas.getOrDefault(t.line + 1, 0) + 1);
            }
        } while (true);

        reader.close();

        // === Reporte de Tokens ===
        System.out.println("=== Tokens encontrados ===");
        for (Map.Entry<String, Map<Integer, Integer>> entry : tokensMap.entrySet()) {
            String lexema = entry.getKey();
            Map<Integer, Integer> ocurrencias = entry.getValue();

            StringBuilder lineasStr = new StringBuilder();
            for (Map.Entry<Integer, Integer> occ : ocurrencias.entrySet()) {
                if (lineasStr.length() > 0) lineasStr.append(", ");
                if (occ.getValue() > 1)
                    lineasStr.append(occ.getKey()).append("(").append(occ.getValue()).append(")");
                else
                    lineasStr.append(occ.getKey());
            }

            System.out.printf("%-15s %s%n", lexema, lineasStr.toString());
        }

        // === Errores léxicos ===
        System.out.println("\n=== Errores léxicos ===");
        if (erroresLexicos.isEmpty())
            System.out.println("No se encontraron errores léxicos.");
        else
            erroresLexicos.forEach(System.out::println);

        // === Análisis Sintáctico ===
        System.out.println("\n=== Análisis Sintáctico ===");
        try (FileReader fr = new FileReader(inputFile)) {
            Lexer newLexer = new Lexer(fr);
            Adaptador adaptador = new Adaptador(newLexer);
            Parser parser = new Parser(adaptador);

            parser.parse();

            // Mostrar errores sintácticos (si existen)
            if (!parser.getErroresSintacticos().isEmpty()) {
                System.out.println("\n=== Errores Sintácticos ===");
                parser.getErroresSintacticos().forEach(System.out::println);
            } else {
                System.out.println("✅ Análisis sintáctico completado sin errores.");
            }

        } catch (Exception e) {
            System.err.println("❌ Error durante el análisis sintáctico:");
            System.err.println("   " + (e.getMessage() != null ? e.getMessage() : e.getClass().getName()));
        }
    }
}

