package joaopitarelo.tasksave.api.infraestruture.security;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;

public class HashUtil {

    // Métudo que recebe uma String e volta ela em formato Hash
    public static String generateHash(String string) throws NoSuchAlgorithmException {
        // Capturando o algoritmos de criptografia
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        // Usando esse algoritmo para aplicar a um array de bytes -> string.getBytes() o que retorna um array de bytes
        // criptografado
        byte[] bytesHash = digest.digest(string.getBytes());

        // Transformando o array de bytes em uma String hexadicimal com o HexFormat
        String hexacimalHash = HexFormat.of().formatHex(bytesHash);

        return hexacimalHash;
    }
}
