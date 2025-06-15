package joaopitarelo.tasksave.api.application.services;

import jakarta.transaction.Transactional;
import joaopitarelo.tasksave.api.domain.category.Category;
import joaopitarelo.tasksave.api.domain.user.User;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;


@SpringBootTest
@ActiveProfiles("test")
@Transactional
class CategoryServiceTest {

    @Autowired
    private CategoryService categoryService;
    @Autowired
    private AuthenticationService authenticationService;

    @Test
    void getAllCategories() {
    }

    @Test
    void getById() {
    }

    @Test
    @DisplayName("Testando a criação de categorias e validando se ele foi inserido no banco de dados")
    void createCategory_ShouldCreateCategoryInDatabase() {
        // Criando as entidades
        User user = createUser();
        Category category = createCategory(user);

        // Chamando os métudo que queremos testar
        categoryService.createCategory(category);

        // Buscando o categoria salvo no balco
        var savedCategory = categoryService.getById(category.getId(), user.getId());

        // Validando se a categoria salvo foi encontrado
        assertNotNull(savedCategory);

        // Verificando se o categoria retornado foi realmente o que inserimos
        assertEquals(category.getId(), savedCategory.getId());
    }

    @Test
    void updateCategory() {
    }

    @Test
    void deleteCategory() {
    }

    private User createUser() {
        User user = new User();
        user.setLogin("fulano.silva@email.com");
        user.setPassword("MyPassword123%");
        authenticationService.saveUser(user);
        return user;
    }

    private Category createCategory(User user) {
        Category category = new Category();
        category.setColor("#ABC123");
        category.setDescription("Faculdade");
        category.setUser(user);
        category.setAtivo(true);
        return category;
    }


}