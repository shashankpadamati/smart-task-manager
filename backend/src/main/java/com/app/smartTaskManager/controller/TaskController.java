package com.app.smartTaskManager.controller;

import java.util.List;

import com.app.smartTaskManager.dto.TaskDTO;
import com.app.smartTaskManager.models.Task;
import com.app.smartTaskManager.service.TaskService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;


@RestController
@RequiredArgsConstructor
@RequestMapping("/tasks")
public class TaskController {

    private final TaskService taskService;
  
    @GetMapping
    public List<Task> getAllTasks() {
        return taskService.getAllTasks();
    }    

    @PostMapping
    public Task createTask(@RequestBody TaskDTO dto) {
        return taskService.createTask(dto);
    }

    @GetMapping("/{id}")
    public Task getTaskById(@PathVariable Long id) {
        return taskService.getTaskById(id);
    }

    @PutMapping("/{id}")
    public Task updateTask(@PathVariable Long id, @RequestBody TaskDTO dto){
        return taskService.updateTask(id, dto);
    }
    
    @DeleteMapping("/{id}")
    public void deleteTask(@PathVariable long id){
        taskService.deleteTask(id);
    }

    @PatchMapping("/{id}/complete")
    public Task markComplete(@PathVariable long id){
        return taskService.markComplete(id);
    }
}
