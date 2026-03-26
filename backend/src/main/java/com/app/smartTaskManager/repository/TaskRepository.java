package com.app.smartTaskManager.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import com.app.smartTaskManager.models.Task;

public interface TaskRepository extends JpaRepository<Task, Long>, JpaSpecificationExecutor<Task> {

    public List<Task> findByUserId(Long userId, Sort sort);

    Optional<Task> findByIdAndUserId(Long id, Long userId);
}
