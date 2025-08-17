package joaopitarelo.tasksave.api.interfaces.controller;

import jakarta.transaction.Transactional;
import jakarta.validation.Valid;

import joaopitarelo.tasksave.api.application.services.CategoryService;
import joaopitarelo.tasksave.api.domain.category.Category;
import joaopitarelo.tasksave.api.domain.user.User;
import joaopitarelo.tasksave.api.domain.exceptions.CategoryNotFoundException;
import joaopitarelo.tasksave.api.domain.exceptions.InvalidPositionException;
import joaopitarelo.tasksave.api.interfaces.dtos.category.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("category")
public class CategoryController {

    @Autowired
    private CategoryService categoryService;

    @GetMapping
    public ResponseEntity<Map<String, List<OutputCategory>>> getAll(@AuthenticationPrincipal User user) {
        Map<String, List<OutputCategory>> categoryList = Map.of(
                "categories", categoryService.getAll(user.getId()).stream().map(OutputCategory::new).toList()
        );
        return ResponseEntity.ok(categoryList);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Long id, @AuthenticationPrincipal User user) {
        Category category = categoryService.getById(id, user.getId());

        if (category == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).build();

        return ResponseEntity.ok(Map.of("category", new OutputCategory(category)));
    }

    @PostMapping("/create")
    @Transactional
    public ResponseEntity<Map<String, OutputCategory>> create(@RequestBody @Valid CreateCategory newCategory,
                                                 UriComponentsBuilder uriBuilder,
                                                 @AuthenticationPrincipal User user) {

        Category category = new Category(newCategory);
        category.setUser(user);
        categoryService.create(category);

        var uri = uriBuilder.path("/category/{id}").buildAndExpand(category.getId()).toUri();

        return ResponseEntity.created(uri).body(Map.of("category",new OutputCategory(category)));
    }

    @PutMapping("/{categoryId}")
    @Transactional
    public ResponseEntity<?> update(@RequestBody @Valid UpdateCategory modifiedCategory,
                                    @PathVariable Long categoryId,
                                    @AuthenticationPrincipal User user) {
        Category category = categoryService.getById(categoryId, user.getId());

        if (category == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        if (category.isDefault()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("message", "default category updating is not allowed"));
        }

        try {
            categoryService.update(category, modifiedCategory);
        } catch (InvalidPositionException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", e.getMessage()));
        }

        return ResponseEntity.ok(Map.of("category", new OutputCategory(category)));
    }

    @DeleteMapping("/{categoryId}")
    @Transactional
    public ResponseEntity<?> delete(@PathVariable Long categoryId, @AuthenticationPrincipal User user) {
        try {
            categoryService.delete(categoryId, user.getId());
        } catch (CategoryNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        return ResponseEntity.noContent().build();
    }
}
