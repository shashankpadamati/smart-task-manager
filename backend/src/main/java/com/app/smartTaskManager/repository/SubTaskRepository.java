package com.app.smartTaskManager.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import com.app.smartTaskManager.models.SubTask;

public interface SubTaskRepository extends JpaRepository <SubTask, Long> {

        
}
