package com.app.smartTaskManager.service;

import java.util.List;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import com.app.smartTaskManager.dto.TaskDTO;
import com.app.smartTaskManager.models.Task;
import com.app.smartTaskManager.repository.TaskRepository;

@Service
public class TaskService {
   
    private final TaskRepository taskRepository;

    public TaskService(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    public List<Task> getAllTasks() {
        return taskRepository.findAll(
                Sort.by(Sort.Direction.DESC, "createdAt")
        );
    }   

    public Task getTaskById(Long id) {
        return taskRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Task not found"));
    }
    
    public Task createTask(TaskDTO dto) {
        Task task = new Task(); 
        task.setTitle(dto.getTitle());
        task.setDescription(dto.getDescription());
        task.setTags(dto.getTags());
        if (dto.getPriority() != null) {
            task.setPriority(Task.Priority.valueOf(dto.getPriority().toUpperCase()));
        }
        return taskRepository.save(task);
        // try {
        //     task.setPriority(Task.Priority.valueOf(dto.getPriority().toUpperCase()));
        // } catch (Exception e) {
        //     throw new IllegalArgumentException("Invalid priority value");
        // }        
    }

    public Task updateTask(Long id, TaskDTO dto) {
        Task task = getTaskById(id);

        task.setTitle(dto.getTitle());
        task.setDescription(dto.getDescription());
        task.setTags(dto.getTags());
        if (dto.getPriority() != null) {
            task.setPriority(Task.Priority.valueOf(dto.getPriority().toUpperCase()));
        }

        return taskRepository.save(task);
    }

    public void deleteTask(Long id) {
        taskRepository.deleteById(id);
    }

    public Task markComplete(Long id) {
        Task task = getTaskById(id);
        task.setCompleted(true);
        return taskRepository.save(task);
    }

} 
