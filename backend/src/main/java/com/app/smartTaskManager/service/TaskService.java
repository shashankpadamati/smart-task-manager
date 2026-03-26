package com.app.smartTaskManager.service;


import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;


import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import com.app.smartTaskManager.dto.SubTaskDTO;
import com.app.smartTaskManager.dto.TaskDTO;
import com.app.smartTaskManager.dto.response.TaskResponse;
import com.app.smartTaskManager.models.SubTask;
import com.app.smartTaskManager.models.Tag;
import com.app.smartTaskManager.models.Task;
import com.app.smartTaskManager.models.User;
import com.app.smartTaskManager.repository.TagRepository;
import com.app.smartTaskManager.repository.TaskRepository;
import com.app.smartTaskManager.repository.UserRepository;

@Service
public class TaskService {
    private final UserRepository userRepository;
    private final TaskRepository taskRepository;
    private final TagRepository tagRepository;

    public TaskService(TaskRepository taskRepository, UserRepository userRepository, TagRepository tagRepository) {
        this.taskRepository = taskRepository;
        this.userRepository = userRepository;
        this.tagRepository = tagRepository;
    }

    // get all tasks for a user with filtering and sorting
    public List<TaskResponse> getTasksByUser(Long userId, Boolean completed, String priority, String tagName, String search, String sortBy) {
        Specification<Task> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            // Filter by authenticated user
            predicates.add(cb.equal(root.get("user").get("id"), userId));

            // Focus Filters
            if (completed != null) {
                predicates.add(cb.equal(root.get("completed"), completed));
            }

            if (priority != null) {
                try {
                    Task.Priority p = Task.Priority.valueOf(priority.toUpperCase());
                    predicates.add(cb.equal(root.get("priority"), p));
                } catch (IllegalArgumentException ignored) {}
            }

            // Tagging System Filter
            if (tagName != null && !tagName.isEmpty()) {
                Join<Task, Tag> tagJoin = root.join("tags");
                predicates.add(cb.equal(tagJoin.get("name"), tagName));
            }

            // Search functionality
            if (search != null && !search.isEmpty()) {
                String searchPattern = "%" + search.toLowerCase() + "%";
                Predicate titleSearch = cb.like(cb.lower(root.get("title")), searchPattern);
                Predicate descSearch = cb.like(cb.lower(root.get("description")), searchPattern);
                predicates.add(cb.or(titleSearch, descSearch));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };

        // Smart Sorting System
        Sort sort;
        if ("alphabetical".equalsIgnoreCase(sortBy)) {
            sort = Sort.by(Sort.Direction.ASC, "title");
        } else {
            // Default: Newest first
            sort = Sort.by(Sort.Direction.DESC, "createdAt");
        }

        Sort finalSort = Sort.by(Sort.Direction.ASC, "completed").and(sort);

        List<TaskResponse> responses = taskRepository.findAll(spec, finalSort).stream()
                .map(TaskResponse::fromEntity)
                .collect(Collectors.toList());

        if ("priority".equalsIgnoreCase(sortBy)) {
            responses.sort((t1, t2) -> {
                int c1 = Boolean.compare(t1.isCompleted(), t2.isCompleted());
                if (c1 != 0) return c1;
                
                String prio1 = t1.getPriority() != null ? t1.getPriority().toUpperCase() : "MEDIUM";
                String prio2 = t2.getPriority() != null ? t2.getPriority().toUpperCase() : "MEDIUM";
                
                int p1 = Task.Priority.valueOf(prio1).ordinal();
                int p2 = Task.Priority.valueOf(prio2).ordinal();
                if (p1 != p2) return Integer.compare(p2, p1); // DESC for HIGH > LOW
                
                return t2.getCreatedAt().compareTo(t1.getCreatedAt()); // DESC
            });
        }

        return responses;
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

        // Map tags from DTO
        if (dto.getTags() != null && !dto.getTags().isEmpty()) {
            task.setTags(mapTagsFromDto(dto.getTags(), user));
        }

        return TaskResponse.fromEntity(taskRepository.save(task));
    }

    // update task
    public TaskResponse updateTask(Long userId, Long taskId, TaskDTO dto) {
        Task task = getTaskEntity(userId, taskId);
        User user = task.getUser();

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

        // Re-map tags from DTO
        if (dto.getTags() != null) {
            task.getTags().clear();
            task.getTags().addAll(mapTagsFromDto(dto.getTags(), user));
        }

        return TaskResponse.fromEntity(taskRepository.save(task));
    }

    private Set<Tag> mapTagsFromDto(List<String> tagNames, User user) {
        Set<Tag> tags = new HashSet<>();
        for (String tagName : tagNames) {
            Tag tag = tagRepository.findByNameAndUserId(tagName, user.getId())
                    .orElseGet(() -> tagRepository.save(new Tag(tagName, user)));
            tags.add(tag);
        }
        return tags;
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
