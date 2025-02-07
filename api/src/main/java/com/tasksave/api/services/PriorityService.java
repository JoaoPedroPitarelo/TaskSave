package com.tasksave.api.services;

import com.tasksave.api.models.Priority;
import com.tasksave.api.repository.PriorityRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor // usado para gerar automaticamente um construtor para todos os campos 'final' ou campos marcados com @NonNull, como se fosse um injetor de dependências
public class PriorityService {
    // Nessa classe terão todos os métodos relacionado ao "serviço" prioridade
    private final PriorityRepository priorityRepository;

    public Priority savePriority(Priority priority) {
        return priorityRepository.save(priority);
    }

    public List<Priority> listPriority() {
        return priorityRepository.findAll();
    }
}
