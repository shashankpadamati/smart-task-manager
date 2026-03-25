package com.app.smartTaskManager.models;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class SubTask {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column(nullable = false)
    private String title;

    private boolean completed = false;

    // Many SubTasks → One Task (bidirectional optional)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "task_id")
    private Task task;

}
