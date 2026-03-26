package com.app.smartTaskManager.service;

import org.springframework.stereotype.Service;

import com.app.smartTaskManager.dto.response.SubTaskResponse;
import com.app.smartTaskManager.models.SubTask;
import com.app.smartTaskManager.models.Task;
import com.app.smartTaskManager.repository.SubTaskRepository;
import com.app.smartTaskManager.repository.TaskRepository;

import lombok.RequiredArgsConstructor;


@Service
@RequiredArgsConstructor
public class SubTaskService {
    private final SubTaskRepository subTaskRepository;
    private final TaskRepository taskRepository;

    
    // create subtask
    public SubTaskResponse createSubTask(Long userId, Long taskId, String title) {

        Task task = taskRepository.findByIdAndUserId(taskId, userId)
                .orElseThrow(() -> new RuntimeException("Task not found or unauthorized"));

        SubTask subTask = new SubTask();
        subTask.setTitle(title);
        subTask.setTask(task);

        return SubTaskResponse.fromEntity(subTaskRepository.save(subTask));
    }

    
    // delete subtask
    public void deleteSubTask(Long userId, Long taskId, Long subTaskId) {
        Task task = taskRepository.findByIdAndUserId(taskId, userId)
                .orElseThrow(() -> new RuntimeException("Task not found or unauthorized"));

        SubTask subTask = subTaskRepository.findById(subTaskId)
                .orElseThrow(() -> new RuntimeException("Subtask not found"));

        if (!subTask.getTask().getId().equals(task.getId())) {
            throw new RuntimeException("Subtask does not belong to this task");
        }

        subTaskRepository.delete(subTask);
    }

    // toggle subtask complete
    public SubTaskResponse toggleSubTaskComplete(Long userId, Long taskId, Long subTaskId) {

        Task task = taskRepository.findByIdAndUserId(taskId, userId)
                .orElseThrow(() -> new RuntimeException("Task not found or unauthorized"));

        SubTask subTask = subTaskRepository.findById(subTaskId)
                .orElseThrow(() -> new RuntimeException("Subtask not found"));

        if (!subTask.getTask().getId().equals(task.getId())) {
            throw new RuntimeException("Subtask does not belong to this task");
        }

        subTask.setCompleted(!subTask.isCompleted());
        return SubTaskResponse.fromEntity(subTaskRepository.save(subTask));
    }
}