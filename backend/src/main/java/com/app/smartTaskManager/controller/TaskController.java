package com.app.smartTaskManager.controller;

import java.util.List;

import com.app.smartTaskManager.dto.TaskDTO;
import com.app.smartTaskManager.dto.response.TaskResponse;
import com.app.smartTaskManager.security.services.UserDetailsImpl;
import com.app.smartTaskManager.service.TaskService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;


@RestController
@RequiredArgsConstructor
@RequestMapping("/api/tasks")
public class TaskController {

    private final TaskService taskService;
    
    // get all tasks for the authenticated user
    @GetMapping
    public List<TaskResponse> getAllTasks(@AuthenticationPrincipal UserDetailsImpl currentUser) {
        return taskService.getTasksByUser(currentUser.getId());
    }    

    // create task
    @PostMapping
    public TaskResponse createTask(@AuthenticationPrincipal UserDetailsImpl currentUser, @RequestBody TaskDTO dto) {
        return taskService.createTask(currentUser.getId(), dto);
    }

    // get task by id
    @GetMapping("/{taskId}")
    public TaskResponse getTaskById(@AuthenticationPrincipal UserDetailsImpl currentUser, @PathVariable Long taskId){
        return taskService.getTaskById(currentUser.getId(), taskId);
    }

    // update task
    @PutMapping("/{taskId}")
    public TaskResponse updateTask(@AuthenticationPrincipal UserDetailsImpl currentUser, @PathVariable Long taskId, @RequestBody TaskDTO dto){
        return taskService.updateTask(currentUser.getId(), taskId, dto);
    }
    
    // delete task
    @DeleteMapping("/{taskId}")
    public void deleteTask(@AuthenticationPrincipal UserDetailsImpl currentUser, @PathVariable Long taskId){
        taskService.deleteTask(currentUser.getId(), taskId);
    }

    // toggle complete
    @PatchMapping("/{taskId}/complete")
    public TaskResponse toggleComplete(@AuthenticationPrincipal UserDetailsImpl currentUser, @PathVariable Long taskId){
        return taskService.toggleComplete(currentUser.getId(), taskId);
    }
}
