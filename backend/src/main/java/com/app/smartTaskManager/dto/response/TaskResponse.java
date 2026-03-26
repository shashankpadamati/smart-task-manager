package com.app.smartTaskManager.dto.response;

import com.app.smartTaskManager.models.Task;
import com.app.smartTaskManager.models.Tag;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

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

    public static TaskResponse fromEntity(Task task) {
        TaskResponse response = new TaskResponse();
        response.setId(task.getId());
        response.setTitle(task.getTitle());
        response.setDescription(task.getDescription());
        response.setCompleted(task.isCompleted());
        response.setCreatedAt(task.getCreatedAt());
        response.setPriority(task.getPriority() != null ? task.getPriority().name() : null);
        response.setDueDate(task.getDueDate());
        
        if (task.getSubtasks() != null) {
            response.setSubtasks(task.getSubtasks().stream()
                    .map(SubTaskResponse::fromEntity)
                    .collect(Collectors.toList()));
        }
        
        if (task.getTags() != null) {
            response.setTags(task.getTags().stream()
                    .map(Tag::getName)
                    .collect(Collectors.toList()));
        }
        
        return response;
    }
}
