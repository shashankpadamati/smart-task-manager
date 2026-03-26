package com.app.smartTaskManager.dto.response;

import com.app.smartTaskManager.models.SubTask;
import lombok.Data;

@Data
public class SubTaskResponse {
    private Long id;
    private String title;
    private boolean completed;

    public static SubTaskResponse fromEntity(SubTask subTask) {
        SubTaskResponse response = new SubTaskResponse();
        response.setId(subTask.getId());
        response.setTitle(subTask.getTitle());
        response.setCompleted(subTask.isCompleted());
        return response;
    }
}
