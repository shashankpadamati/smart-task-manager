package com.app.smartTaskManager.service;


import java.util.List;
import java.util.stream.Collectors;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import com.app.smartTaskManager.dto.SubTaskDTO;
import com.app.smartTaskManager.dto.TaskDTO;
import com.app.smartTaskManager.dto.response.TaskResponse;
import com.app.smartTaskManager.models.SubTask;
import com.app.smartTaskManager.models.Task;
import com.app.smartTaskManager.models.User;
import com.app.smartTaskManager.repository.TaskRepository;
import com.app.smartTaskManager.repository.UserRepository;

@Service
public class TaskService {
    private final UserRepository userRepository;
    private final TaskRepository taskRepository;

    public TaskService(TaskRepository taskRepository, UserRepository userRepository) {
        this.taskRepository = taskRepository;
        this.userRepository = userRepository;
    }

    // get all tasks for a user
    public List<TaskResponse> getTasksByUser(Long userId) {
        return taskRepository.findByUserId(userId, Sort.by(Sort.Direction.DESC, "createdAt"))
                .stream()
                .map(TaskResponse::fromEntity)
                .collect(Collectors.toList());
    }

    // get task by id (internal — returns entity)
    private Task getTaskEntity(Long userId, Long taskId) {
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found"));

        if (!task.getUser().getId().equals(userId)) {
            throw new RuntimeException("Unauthorized access");
        }
        return task;
    }

    // get task by id (public — returns DTO)
    public TaskResponse getTaskById(Long userId, Long taskId) {
        return TaskResponse.fromEntity(getTaskEntity(userId, taskId));
    }

    // create task
    public TaskResponse createTask(Long userId, TaskDTO dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Task task = new Task();
        task.setTitle(dto.getTitle());
        task.setDescription(dto.getDescription());
        task.setDueDate(dto.getDueDate());
        task.setUser(user);

        if (dto.getPriority() != null) {
            task.setPriority(Task.Priority.valueOf(dto.getPriority().toUpperCase()));
        }

        // Map subtasks from DTO
        if (dto.getSubtasks() != null && !dto.getSubtasks().isEmpty()) {
            List<SubTask> subtasks = dto.getSubtasks().stream().map(subDto -> {
                SubTask subTask = new SubTask();
                subTask.setTitle(subDto.getTitle());
                subTask.setCompleted(subDto.isCompleted());
                return subTask;
            }).collect(Collectors.toList());
            task.setSubtasks(subtasks);
        }

        return TaskResponse.fromEntity(taskRepository.save(task));
    }

    // update task
    public TaskResponse updateTask(Long userId, Long taskId, TaskDTO dto) {
        Task task = getTaskEntity(userId, taskId);

        task.setTitle(dto.getTitle());
        task.setDescription(dto.getDescription());
        task.setDueDate(dto.getDueDate());

        if (dto.getPriority() != null) {
            task.setPriority(Task.Priority.valueOf(dto.getPriority().toUpperCase()));
        }

        // Re-map subtasks from DTO
        if (dto.getSubtasks() != null) {
            task.getSubtasks().clear();
            for (SubTaskDTO subDto : dto.getSubtasks()) {
                SubTask subTask = new SubTask();
                subTask.setTitle(subDto.getTitle());
                subTask.setCompleted(subDto.isCompleted());
                task.getSubtasks().add(subTask);
            }
        }

        return TaskResponse.fromEntity(taskRepository.save(task));
    }

    // delete task
    public void deleteTask(Long userId, Long taskId) {
        Task task = getTaskEntity(userId, taskId);
        taskRepository.delete(task);
    }

    // toggle complete
    public TaskResponse toggleComplete(Long userId, Long taskId) {
        Task task = getTaskEntity(userId, taskId);
        task.setCompleted(!task.isCompleted());
        return TaskResponse.fromEntity(taskRepository.save(task));
    }
} 
