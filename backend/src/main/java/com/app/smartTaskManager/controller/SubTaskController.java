package com.app.smartTaskManager.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import com.app.smartTaskManager.dto.SubTaskDTO;
import com.app.smartTaskManager.models.SubTask;
import com.app.smartTaskManager.security.services.UserDetailsImpl;
import com.app.smartTaskManager.service.SubTaskService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/tasks/{taskId}/subtasks")
@RequiredArgsConstructor
public class SubTaskController {
    private final SubTaskService subTaskService;

    // create subtask
    @PostMapping
    public SubTask createSubTask(@AuthenticationPrincipal UserDetailsImpl currentUser, @PathVariable Long taskId, @RequestBody SubTaskDTO dto) {
        return subTaskService.createSubTask(currentUser.getId(), taskId, dto.getTitle());
    }

    // delete subtask
    @DeleteMapping("/{subTaskId}")
    public void deleteSubTask(@AuthenticationPrincipal UserDetailsImpl currentUser, @PathVariable Long taskId, @PathVariable Long subTaskId) {
        subTaskService.deleteSubTask(currentUser.getId(), taskId, subTaskId);
    }

    // toggle subtask complete
    @PatchMapping("/{subTaskId}/complete")
    public SubTask toggleSubTaskComplete(@AuthenticationPrincipal UserDetailsImpl currentUser, @PathVariable Long taskId, @PathVariable Long subTaskId) {
        return subTaskService.toggleSubTaskComplete(currentUser.getId(), taskId, subTaskId);
    }
}
