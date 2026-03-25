package com.app.smartTaskManager.controller;

import org.springframework.web.bind.annotation.*;

import com.app.smartTaskManager.dto.SubTaskDTO;
import com.app.smartTaskManager.models.SubTask;
import com.app.smartTaskManager.service.SubTaskService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/users/{userId}/tasks/{taskId}/subtasks")
@RequiredArgsConstructor
public class SubTaskController {
    private final SubTaskService subTaskService;

    // create subtask
    @PostMapping
    public SubTask createSubTask(@PathVariable Long userId, @PathVariable Long taskId, @RequestBody SubTaskDTO dto) {
        return subTaskService.createSubTask(userId, taskId, dto.getTitle());
    }

    // delete subtask
    @DeleteMapping("/{subTaskId}")
    public void deleteSubTask(@PathVariable Long userId, @PathVariable Long taskId, @PathVariable Long subTaskId) {
        subTaskService.deleteSubTask(userId, taskId, subTaskId);
    }

    // toggle subtask complete
    @PatchMapping("/{subTaskId}/complete")
    public SubTask toggleSubTaskComplete(@PathVariable Long userId, @PathVariable Long taskId, @PathVariable Long subTaskId) {
        return subTaskService.toggleSubTaskComplete(userId, taskId, subTaskId);
    }
}
