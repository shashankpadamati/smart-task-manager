package com.app.smartTaskManager.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class TaskDTO {
    private String title;
    private String description;
    private String priority;
    private LocalDateTime dueDate;
    private List<SubTaskDTO> subtasks;

    // have to work on this part
    private List<String> tags;
}