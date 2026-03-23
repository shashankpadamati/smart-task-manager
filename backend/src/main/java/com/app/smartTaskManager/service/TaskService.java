package com.app.smartTaskManager.service;

import java.util.List;
import org.springframework.stereotype.Service;
import com.app.smartTaskManager.models.Task;
import com.app.smartTaskManager.repository.TaskRepository;

@Service
public class TaskService {
   
    private final TaskRepository taskRepository;

    public TaskService(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    public List<Task> getTasks() {
        return taskRepository.findAll();
    }   

} 
