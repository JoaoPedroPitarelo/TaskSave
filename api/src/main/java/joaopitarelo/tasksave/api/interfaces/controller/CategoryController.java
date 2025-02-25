package joaopitarelo.tasksave.api.interfaces.controller;

import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.interfaces.dtos.category.CreateCategory;
import joaopitarelo.tasksave.api.interfaces.dtos.category.OutputCategory;
import joaopitarelo.tasksave.api.interfaces.dtos.category.UpdateCategory;
import joaopitarelo.tasksave.api.domain.category.Category;
import joaopitarelo.tasksave.api.application.services.CategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;

@RestController
@RequestMapping("category")
public class CategoryController {

    @Autowired // Injeção de depêndencias
    private CategoryService categoryService;

    // GetAll --------------------------------------------
    @GetMapping
    public ResponseEntity<List<OutputCategory >> getAll(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(categoryService.getAllCategories(user.getId()).stream().map(OutputCategory::new).toList());
    }

    // GetById ------------------------------------------
    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Long id, @AuthenticationPrincipal User user) {
        Category category = categoryService.getCategoryById(id, user.getId());

        if (category == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Category not found");

        return ResponseEntity.ok(new OutputCategory(category));
    }

    // Create ------------------------------------------
    @PostMapping("/create")
    @Transactional
    public ResponseEntity<OutputCategory> create(@RequestBody @Valid CreateCategory newCategory,
                                                 UriComponentsBuilder uriBuilder,
                                                 @AuthenticationPrincipal User user) { // O parâmetro @RequestBody só pode ter um, pois cada requisição há somente um corpo

        Category category = new Category(newCategory);
        category.setUser(user);
        categoryService.createCategory(category);

        // O que o uriBuilder faz esse pagar o endereço em que o servidor está a rodar que poderá mudar dependendo
        // do ip do servidor, se for local, seria 127.0.0.1, se for uma cloud vai ser alguma coisa 192.168...
        var uri = uriBuilder.path("/category/{id}").buildAndExpand(category.getId()).toUri();

        return ResponseEntity.created(uri).body(new OutputCategory(category));
    }

    // Update ------------------------------------------
    @PutMapping("/{categoryId}")
    @Transactional
    public ResponseEntity<?> update(@RequestBody @Valid UpdateCategory modifiedCategory,
                                    @PathVariable Long categoryId,
                                    @AuthenticationPrincipal User user) {
        Category category = categoryService.getCategoryById(categoryId, user.getId());

        if (category == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Category not found");

        categoryService.updateCategory(category, modifiedCategory);
        return ResponseEntity.ok(new OutputCategory(category));
    }

    // Delete ----------------------------------------
    @DeleteMapping("/{categoryId}")
    @Transactional
    public ResponseEntity<String> delete(@PathVariable Long categoryId, @AuthenticationPrincipal User user) {
        categoryService.deleteCategory(categoryId, user.getId());
        return ResponseEntity.noContent().build();
    }
}
