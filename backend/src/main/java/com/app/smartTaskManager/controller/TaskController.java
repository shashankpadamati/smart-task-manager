package com.app.smartTaskManager.controller;

import java.util.List;

import org.springframework.web.bind.annotation.RequestMapping;
import com.app.smartTaskManager.models.Task;
import com.app.smartTaskManager.service.TaskService;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.PostMapping;



@RestController
@RequestMapping("/tasks")
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }    

    @GetMapping 
    public String getTasks() {
        // Logic to get all tasks
        List<Task> tasks = taskService.getTasks();

        // Return tasks to the view
        return "tasks"; // Assuming this is the name of the view template
    }    

    @PostMapping()
    public String creatTask (@RequestParam String entity) {
        //TODO: process POST request
        
        return entity;
    }
    
}
