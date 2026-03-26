package com.app.smartTaskManager.dto.response;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import com.app.smartTaskManager.models.Task;
import lombok.Data;

@Data
public class TaskResponse {
    private Long id;
    private String title;
    private String description;
    private boolean completed;
    private LocalDateTime createdAt;
    private String priority;
    private LocalDateTime dueDate;
    private List<SubTaskResponse> subtasks;
    private List<String> tags;
    private boolean isOverdue;

    public static TaskResponse fromEntity(Task task) {
        TaskResponse response = new TaskResponse();
        response.setId(task.getId());
        response.setTitle(task.getTitle());
        response.setDescription(task.getDescription());
        response.setCompleted(task.isCompleted());
        response.setCreatedAt(task.getCreatedAt());
        response.setPriority(task.getPriority().name());
        response.setDueDate(task.getDueDate());

        // Overdue check
        if (task.getDueDate() != null && !task.isCompleted()) {
            response.setOverdue(task.getDueDate().isBefore(LocalDateTime.now()));
        } else {
            response.setOverdue(false);
        }

        if (task.getSubtasks() != null) {
            response.setSubtasks(
                task.getSubtasks().stream()
                    .map(SubTaskResponse::fromEntity)
                    .collect(Collectors.toList())
            );
        } else {
            response.setSubtasks(Collections.emptyList());
        }

        if (task.getTags() != null) {
            response.setTags(
                task.getTags().stream()
                    .map(com.app.smartTaskManager.models.Tag::getName)
                    .collect(Collectors.toList())
            );
        } else {
            response.setTags(Collections.emptyList());
        }

        return response;
    }
}
