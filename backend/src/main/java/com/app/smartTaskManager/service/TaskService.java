package com.app.smartTaskManager.service;

import java.util.List;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import com.app.smartTaskManager.dto.TaskDTO;
import com.app.smartTaskManager.models.Task;
import com.app.smartTaskManager.models.User;
import com.app.smartTaskManager.repository.TaskRepository;
import com.app.smartTaskManager.repository.UserRepository;

// import lombok.RequiredArgsConstructor;

// @RequiredArgsConstructor
@Service
public class TaskService {
    private final UserRepository userRepository;
    private final TaskRepository taskRepository;

    public TaskService(TaskRepository taskRepository , UserRepository userRepository) {
        this.taskRepository = taskRepository;
        this.userRepository = userRepository;
    }

    // get all tasks for a user
    public List<Task> getTasksByUser(Long userId) {
        return taskRepository.findByUserId(userId, Sort.by(Sort.Direction.DESC, "createdAt"));
    }   

    
    // get task by id
    public Task getTaskById(Long userId, Long taskId) {
        Task task =  taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found"));
        
        if (!task.getUser().getId().equals(userId)) {
        throw new RuntimeException("Unauthorized access");
        }
        return task;
    }


    //create task
    public Task createTask(Long userId, TaskDTO dto) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));

        Task task = new Task(); 
        task.setTitle(dto.getTitle());
        task.setDescription(dto.getDescription());
        // task.setTags(dto.getTags());
        task.setDueDate(dto.getDueDate());
        task.setUser(user); 

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


    // update task
    public Task updateTask(Long userId, Long taskId, TaskDTO dto) {
        Task task = getTaskById(userId, taskId);    

        task.setTitle(dto.getTitle());
        task.setDescription(dto.getDescription());
        // task.setTags(dto.getTags());
        task.setDueDate(dto.getDueDate());


        if (dto.getPriority() != null) {
            task.setPriority(Task.Priority.valueOf(dto.getPriority().toUpperCase()));
        }

        return taskRepository.save(task);
    }


    // delete task
    public void deleteTask(Long userId, Long taskId) {
        Task task = getTaskById(userId, taskId); 
        taskRepository.delete(task);
    }

    // toggle complete
    public Task toggleComplete(Long userId, Long taskId) {
        Task task = getTaskById(userId, taskId);
        task.setCompleted(task.isCompleted() ? false : true); // toggle complete status
        return taskRepository.save(task);
    }

} 
