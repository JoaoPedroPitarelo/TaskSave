package joaopitarelo.tasksave.api.controller;

import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.dto.category.CreateCategory;
import joaopitarelo.tasksave.api.dto.category.OutputCategory;
import joaopitarelo.tasksave.api.dto.category.UpdateCategory;
import joaopitarelo.tasksave.api.model.Category;
import joaopitarelo.tasksave.api.service.CategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("category")
public class CategoryController {

    @Autowired // Injeção de depêndencias
    private CategoryService categoryService;

    // GetAll --------------------------------------------
    @GetMapping
    public ResponseEntity<List<OutputCategory >> getAll() {
        return ResponseEntity.ok(categoryService.getAllCategories().stream().map(OutputCategory::new).toList());
    }

    // GetById ------------------------------------------
    @GetMapping("/{id}")
    public ResponseEntity<OutputCategory> getById(@PathVariable Long id) {
        Category category = categoryService.getCategoryById(id);

        if (category != null) {
            return ResponseEntity.ok(new OutputCategory(category));
        }

        return ResponseEntity.notFound().build();
    }

    // Create ------------------------------------------
    @PostMapping("/create")
    @Transactional
    public ResponseEntity<String> create(@RequestBody @Valid CreateCategory category) { // O parâmetro @RequestBody só pode ter um, pois cada requisição há somente um corpo
        categoryService.createCategory(new Category(category));
        return ResponseEntity.ok("Category criada com sucesso");
    }

    // Update ------------------------------------------
    @PutMapping("/{id}")
    @Transactional
    public ResponseEntity<?> update(@RequestBody @Valid UpdateCategory modifiedCategory, @PathVariable Long id) {
        Category category = categoryService.getCategoryById(id);

        if (category == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Category not found");

        categoryService.updateCategory(category, modifiedCategory);
        return ResponseEntity.ok(new OutputCategory(category));
    }

    // Delete ----------------------------------------
    @DeleteMapping("/{id}")
    @Transactional
    public ResponseEntity<String> delete(@PathVariable Long id) {
        categoryService.deleteCategory(id);
        return ResponseEntity.noContent().build();
    }

}
