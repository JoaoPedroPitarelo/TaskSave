package com.tasksave.api.repository;

import com.tasksave.api.models.Priority;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PriorityRepository extends JpaRepository<Priority, Long>{
    // Por sí só o SpringDataRepository já implementar o CRUD básico para nós,
    // (Create, Read, Update, Delete)
    // Os métodos são save(), findById(), findAll(), delete(), count(), ETC...
}
