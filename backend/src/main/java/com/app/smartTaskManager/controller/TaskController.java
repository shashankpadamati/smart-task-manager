package com.app.smartTaskManager.controller;

import java.util.List;

import com.app.smartTaskManager.dto.TaskDTO;
import com.app.smartTaskManager.models.Task;
import com.app.smartTaskManager.service.TaskService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;


@RestController
@RequiredArgsConstructor
@RequestMapping("/users/{userId}/tasks")
public class TaskController {

    private final TaskService taskService;
    
    // get all tasks for a user
    @GetMapping
    public List<Task> getAllTasks(@PathVariable Long userId) {
        return taskService.getTasksByUser(userId);
    }    

    // create task
    @PostMapping
    public Task createTask(@PathVariable Long userId, @RequestBody TaskDTO dto) {
        return taskService.createTask(userId, dto);
    }

    // get task by id
    @GetMapping("/{taskId}")
    public Task getTaskById(@PathVariable Long userId, @PathVariable Long taskId){
        return taskService.getTaskById(userId, taskId);
    }

    // update task
    @PutMapping("/{taskId}")
    public Task updateTask(@PathVariable Long userId, @PathVariable Long taskId, @RequestBody TaskDTO dto){
        return taskService.updateTask(userId, taskId, dto);
    }
    
    // delete task
    @DeleteMapping("/{taskId}")
    public void deleteTask(@PathVariable Long userId, @PathVariable Long taskId){
        taskService.deleteTask(userId, taskId);
    }

    // toggle complete
    @PatchMapping("/{taskId}/complete")
    public Task toggleComplete(@PathVariable Long userId, @PathVariable Long taskId){
        return taskService.toggleComplete(userId, taskId);
    }
}

