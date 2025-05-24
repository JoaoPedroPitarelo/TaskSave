package joaopitarelo.tasksave.api.application.services;

import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.domain.category.Category;
import joaopitarelo.tasksave.api.infraestruture.persistence.CategoryJpaRepository;
import joaopitarelo.tasksave.api.interfaces.dtos.category.UpdateCategory;
import joaopitarelo.tasksave.api.domain.task.Task;
import joaopitarelo.tasksave.api.infraestruture.persistence.TaskJpaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

// Services só mexem com entidades, os DTO só são para os controllers em que é necessário a tranformação dos dados
// seja para entidades, seja para saída
@Service
public class CategoryService {
    @Autowired
    private CategoryJpaRepository categoryRepository;
    @Autowired
    private TaskJpaRepository taskRepository;

    // GetAll
    public List<Category> getAllCategories(Long userId) {
        return categoryRepository.findByAtivoTrueAndUserId(userId);
    }

    // GetById
    public Category getById(Long idCategory, Long idUser) {
        return categoryRepository.findByIdAndUserIdAndAtivoTrue(idCategory, idUser);
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
    public void deleteCategory(Long categoryId, Long userId) {
        Category category = categoryRepository.findByIdAndUserIdAndAtivoTrue(categoryId, userId);
        List<Task> task_list = category.getTasks();

        task_list.forEach(task -> {
            task.setCompleted(true);
            taskRepository.save(task);
        });
        category.setAtivo(false);
    }
}
