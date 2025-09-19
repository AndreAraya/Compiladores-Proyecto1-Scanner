import java.io.*;
import java.util.*;

public class Main {
    public static void main(String[] args) throws Exception {
        // Archivo de entrada
        String inputFile = (args.length > 0) ? args[0] : "sample.txt";
        BufferedReader reader = new BufferedReader(new FileReader(inputFile));
        Lexer lexer = new Lexer(reader);

        // Estructuras de datos
        Map<String, Map<Integer, Integer>> tokensMap = new LinkedHashMap<>();
        List<String> errores = new ArrayList<>();

        Token t;
        do {
            t = lexer.yylex(); // tu método JFlex devuelve Token

            if (t == null) {
                // Fin de archivo
                break;
            }

            if (t.type == TokenType.ERROR) {
                errores.add(String.format(
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
                if (occ.getValue() > 1) {
                    lineasStr.append(occ.getKey()).append("(").append(occ.getValue()).append(")");
                } else {
                    lineasStr.append(occ.getKey());
                }
            }

            System.out.printf("%-15s %s%n", lexema, lineasStr.toString());
        }

        // === Errores léxicos ===
        System.out.println("\n=== Errores léxicos ===");
        if (errores.isEmpty()) {
            System.out.println("No se encontraron errores léxicos.");
        } else {
            for (String err : errores) {
                System.out.println(err);
            }
        }
    }
}
