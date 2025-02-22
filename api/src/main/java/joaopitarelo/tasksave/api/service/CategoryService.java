package joaopitarelo.tasksave.api.service;

import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.dto.category.UpdateCategory;
import joaopitarelo.tasksave.api.model.Category;
import joaopitarelo.tasksave.api.model.Task;
import joaopitarelo.tasksave.api.repository.CategoryRepository;
import joaopitarelo.tasksave.api.repository.TaskRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

// Services só mexem com entidades, os DTO só são para os controllers em que é necessário a tranformação dos dados
// seja para entidades, seja para saída
@Service
public class CategoryService {
    @Autowired
    private CategoryRepository categoryRepository;
    @Autowired
    private TaskRepository taskRepository;

    // GetAll
    public List<Category> getAllCategories() {
        return categoryRepository.findByAtivoTrue();
    }

    // GetById
    public Category getCategoryById(Long idCategory) {
        return categoryRepository.findByIdAndAtivoTrue(idCategory);
    }

    // Create
    public void createCategory(Category category) {
        category.setAtivo(true);
        categoryRepository.save(category);
    }

    // Update
    public void updateCategory(Category category, @Valid UpdateCategory modifiedCategory) {
        category.setDescription(modifiedCategory.description() != null ? modifiedCategory.description() : category.getDescription());
        category.setColor(modifiedCategory.color() != null ? modifiedCategory.color() : category.getColor());

        categoryRepository.save(category);
    }

    // Delete - todas as tarefas contidas nelas serão deletadas também
    public void deleteCategory(Long id) {
        Category category = categoryRepository.getReferenceById(id);
        List<Task> task_list = category.getTasks();

        task_list.forEach(task -> {
            task.setCompleted(true);
            taskRepository.save(task);
        });
        category.setAtivo(false);
    }
}
