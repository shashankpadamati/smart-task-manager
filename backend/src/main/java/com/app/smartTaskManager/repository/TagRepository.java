package com.app.smartTaskManager.repository;

import com.app.smartTaskManager.models.Tag;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.List;

public interface TagRepository extends JpaRepository<Tag, Long> {
    Optional<Tag> findByNameAndUserId(String name, Long userId);
    List<Tag> findByUserId(Long userId);
}
