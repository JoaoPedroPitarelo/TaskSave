package joaopitarelo.tasksave.api.controller;

import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.dto.category.CreateCategory;
import joaopitarelo.tasksave.api.dto.category.OutputCategory;
import joaopitarelo.tasksave.api.model.Category;
import joaopitarelo.tasksave.api.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("category")
public class CategoryController {

    // TODO delete[]
    // TODO UPDATE[]
    //

    @Autowired // Injeção de depêndencias
    private CategoryRepository categoryRepository;

    // GetAll
    @GetMapping
    public ResponseEntity<List<Category>> getAll() {
        return ResponseEntity.ok(categoryRepository.findAll());
    }

    // GetById
    @GetMapping("/{id}")
    public ResponseEntity<OutputCategory> getById(@PathVariable Long id) {
        Category category = categoryRepository.findById(id).orElseThrow(
                () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Categoria não encontrada")
        );
        return ResponseEntity.ok(new OutputCategory(category));
    }

    // Create
    @PostMapping("/create")
    @Transactional
    public ResponseEntity<String> create(@RequestBody @Valid CreateCategory category) { // O parâmetro @RequestBody só pode ter um, pois cada requisição há somente um corpo
        categoryRepository.save(new Category(category));
        return ResponseEntity.status(HttpStatus.CREATED).body(category.toString());
    }


}
