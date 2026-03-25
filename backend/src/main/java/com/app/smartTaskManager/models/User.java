package com.app.smartTaskManager.models;

import java.util.List;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.Data;

@Entity
@Data
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @NotBlank(message = "Username is a required field")
    private String username;

    @Email(message = "Invalid email format")
    @NotBlank(message = "Email is a required field")
    private String email;

    @Size(min=6,message = "password mustbe atleast of 6 characters")
    private String password;//storing the password without hashing ,do it later

    //  One user → many tasks
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<Task> tasks;
}
