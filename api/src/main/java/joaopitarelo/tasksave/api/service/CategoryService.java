package joaopitarelo.tasksave.api.service;

import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.dto.category.UpdateCategory;
import joaopitarelo.tasksave.api.model.Category;
import joaopitarelo.tasksave.api.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

// Services só mexem com entidades, os DTO só são para os controllers em que é necessário a tranformação dos dados
// seja para entidades, seja para saída
@Service
public class CategoryService {
    @Autowired
    private CategoryRepository categoryRepository;

    // GetAll
    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }

    // GetById
    public Category getCategoryById(Long idCategory) {
        return categoryRepository.findById(idCategory).orElse(null);
    }

    // Create
    public void createCategory(Category category) {
        categoryRepository.save(category);
    }

    // Update
    public void updateCategory(@Valid UpdateCategory modifiedCategory) {
        Category category = categoryRepository.getReferenceById(modifiedCategory.id());
        category.setDescription(modifiedCategory.description() != null ? modifiedCategory.description() : category.getDescription());
        category.setColor(modifiedCategory.color() != null ? modifiedCategory.color() : category.getColor());

        categoryRepository.save(category);
    }
}
