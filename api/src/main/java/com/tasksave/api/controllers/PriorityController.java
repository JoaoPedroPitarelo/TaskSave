package com.tasksave.api.controllers;

import com.tasksave.api.models.Priority;
import com.tasksave.api.services.PriorityService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/prioritys")
// @RequiredArgsConstructor // Injeta as dependências
public class PriorityController {
    private final PriorityService priorityService;

    public PriorityController(PriorityService priorityService) {
        this.priorityService = priorityService;
    }

    @GetMapping("/list")
    public List<Priority> listPrioritys() {
        return priorityService.listPriority();
    }

    @PostMapping("/create")
    public Priority createPriority(@RequestParam String description, @RequestParam String color) {
        return priorityService.savePriority(Priority.builder()
                .description(description)
                .color(color)
                .build());
    }
}

