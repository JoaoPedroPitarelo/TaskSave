package joaopitarelo.tasksave.api.infraestruture.security;

import org.junit.jupiter.api.Test;

import java.security.NoSuchAlgorithmException;

import static org.junit.jupiter.api.Assertions.*;

class HashUtilTest {

    @Test
    void generateHash() throws NoSuchAlgorithmException {
        // Email de teste
        String email = "fulano.silva@email.com";

        // Chamando o métudo hash
        String hash = HashUtil.generateHash(email);
        String hashAux = HashUtil.generateHash(email);

        // Verificando
        assertNotNull(hash); // assertando que não é null
        assertEquals(64, hash.length()); // tamanho esperado de uma String hash
        assertEquals(hash, hashAux); // a mesma string com o mesmo algoritmo tem que dar o mesmo resultado

        System.out.println("Hash: " + hash);
    }
}