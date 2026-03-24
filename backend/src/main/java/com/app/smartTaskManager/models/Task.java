package com.app.smartTaskManager.models;

import java.time.LocalDateTime;
import java.util.List;

import jakarta.persistence.*;
import lombok.*;


@Entity
@Data
public class Task {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column(nullable = false)
    private String title;

    private String description; 
    
    private boolean completed = false;

    private LocalDateTime createdAt = LocalDateTime.now();

    @Enumerated(EnumType.STRING)
    private Priority priority = Priority.MEDIUM;
    public enum Priority {
    LOW, MEDIUM, HIGH
    }

    @ElementCollection
    private List <String> tags;


}

