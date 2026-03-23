package com.app.smartTaskManager.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.app.smartTaskManager.models.Task;

public interface TaskRepository extends JpaRepository<Task, Long> {

    
}
