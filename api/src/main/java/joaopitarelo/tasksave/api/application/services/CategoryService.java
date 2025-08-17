package joaopitarelo.tasksave.api.application.services;

import jakarta.validation.Valid;
import joaopitarelo.tasksave.api.domain.category.Category;
import joaopitarelo.tasksave.api.domain.exceptions.CategoryNotFoundException;
import joaopitarelo.tasksave.api.domain.exceptions.InvalidPositionException;
import joaopitarelo.tasksave.api.infraestruture.persistence.CategoryJpaRepository;
import joaopitarelo.tasksave.api.interfaces.dtos.category.UpdateCategory;
import joaopitarelo.tasksave.api.domain.task.Task;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Stream;

@Service
public class CategoryService {

    @Autowired
    private CategoryJpaRepository categoryRepository;
    @Autowired
    private TaskService taskService;

    public List<Category> getAll(Long userId) {
        return categoryRepository.findByAtivoTrueAndUserIdOrderByPosition(userId);
    }

    public Category getById(Long idCategory, Long idUser) {
        return categoryRepository.findByIdAndUserIdAndAtivoTrue(idCategory, idUser).orElse(null);
    }

    public void create(Category category) {
        category.setAtivo(true);

        Optional<Long> lastPosition = categoryRepository.findMaxPositionByUserAndAtivoTrue(category.getUser().getId());

        if (lastPosition.isEmpty()) {
            category.setPosition(0L);
            categoryRepository.save(category);
            return;
        }

        category.setPosition(lastPosition.get() + 1);
        categoryRepository.save(category);
    }

    public void update(Category category, @Valid UpdateCategory modifiedCategory) {
        category.setDescription(modifiedCategory.description() != null ? modifiedCategory.description() : category.getDescription());
        category.setColor(modifiedCategory.color() != null ? modifiedCategory.color() : category.getColor());


        if (modifiedCategory.position() != null) {
            Long oldPosition = category.getPosition();
            Long newPosition = modifiedCategory.position();

            orderCategoryOnCategoryList(oldPosition, newPosition, category);
        }

        categoryRepository.save(category);
    }

    private void orderCategoryOnCategoryList(Long oldPosition, Long newPosition, Category category) {
        if (Objects.equals(oldPosition, newPosition)) {
            return;
        }

        if (!isAValidPosition(newPosition, category.getUser().getId())) {
            throw new InvalidPositionException("Invalid Position");
        }

        Category categoryOnOldPosition;
        Category categoryOnNewPosition;
        Optional<Category> categoryAtOldPositionOpt = categoryRepository.findByUserIdAndPositionAndAtivoTrue(category.getUser().getId(), oldPosition);
        Optional<Category> categoryAtNewPositonOpt = categoryRepository.findByUserIdAndPositionAndAtivoTrue(category.getUser().getId(), newPosition);

        if (categoryAtOldPositionOpt.isEmpty() || categoryAtNewPositonOpt.isEmpty() ) {
            throw new RuntimeException("Category not found");
        }

        if (Math.abs(oldPosition - newPosition) == 1) {
            categoryOnOldPosition = categoryAtOldPositionOpt.get();
            categoryOnNewPosition = categoryAtNewPositonOpt.get();

            categoryOnOldPosition.setPosition(newPosition);
            categoryOnNewPosition.setPosition(oldPosition);

            categoryRepository.save(categoryOnOldPosition);
            categoryRepository.save(categoryOnNewPosition);
            return;
        }

        if (Math.abs(oldPosition - newPosition) >= 2) {
            Stream<Category> categoriesList = categoryRepository.findByAtivoTrueAndUserIdOrderByPosition(category.getUser().getId()).stream();

            List<Category> newOrdenedList;

            if ((oldPosition - newPosition) < 0) {
                newOrdenedList = categoriesList
                    .filter(c -> c.getPosition() <= newPosition && !c.getPosition().equals(oldPosition) && c.getPosition() > 0)
                    .peek(c -> c.setPosition(c.getPosition() -1L)).toList();
            } else {
                newOrdenedList = categoriesList
                    .filter(c -> c.getPosition() >= newPosition && !c.getPosition().equals(oldPosition) && c.getPosition() < oldPosition)
                    .peek(c -> c.setPosition(c.getPosition() +1L)).toList();
            }

            category.setPosition(newPosition);
            categoryRepository.save(category);

            categoryRepository.saveAll(newOrdenedList);
        }
    }

    private boolean isAValidPosition(Long position, Long userId) {
        int categoryListSize = categoryRepository.findByAtivoTrueAndUserIdOrderByPosition(userId).size();

        if (position > categoryListSize -1) {
            return false;
        }

        return position >= 0;
    }

    public void delete(Long categoryId, Long userId) {
        Optional<Category> categoryOptional = categoryRepository.findByIdAndUserIdAndAtivoTrue(categoryId, userId);

        if (categoryOptional.isEmpty()) {
            throw new CategoryNotFoundException("category not found");
        }

        Category category = categoryOptional.get();

        List<Task> taskList = category.getTasks();
        taskList.forEach(task -> taskService.delete(task));

        category.setAtivo(false);
        categoryRepository.save(category);
        reorderPositionListAfterDelete(category.getPosition(), category.getUser().getId());
    }

    private void reorderPositionListAfterDelete(Long deletedCategoryPosition, Long userId) {
        Stream<Category> categoriesList = categoryRepository.findByAtivoTrueAndUserIdOrderByPosition(userId).stream();

        List<Category> newOrdenedList = categoriesList
                .filter(category -> category.getPosition() > deletedCategoryPosition)
                .peek(category -> category.setPosition(category.getPosition() -1L)).toList();

        categoryRepository.saveAll(newOrdenedList);
    }

    public Category getDefaultCategory(Long userId) {
        return categoryRepository.findByUserIdAndIsDefaultTrue(userId);
    }
}
