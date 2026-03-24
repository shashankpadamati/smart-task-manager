package com.app.smartTaskManager.dto;

import lombok.Data;
import java.util.List;

@Data
public class TaskDTO {
    private String title;
    private String description;
    private String priority;
    private List<String> tags;
}