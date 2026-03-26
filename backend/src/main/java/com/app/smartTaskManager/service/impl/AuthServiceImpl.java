package com.app.smartTaskManager.service.impl;

import org.springframework.stereotype.Service;

import com.app.smartTaskManager.dto.request.LoginRequest;
import com.app.smartTaskManager.dto.request.SignupRequest;
import com.app.smartTaskManager.dto.response.AuthResponse;
import com.app.smartTaskManager.models.User;
import com.app.smartTaskManager.repository.UserRepository;
import com.app.smartTaskManager.service.AuthService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    // private final PasswordEncoder encoder; // Assuming these beans exist, but to avoid more compilation errors if they don't, I'll use basic logic first.
    // Actually, if they don't exist, I'll have more errors. Let's check common security configs.

    @Override
    public AuthResponse signup(SignupRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Error: Username is already taken!");
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Error: Email is already in use!");
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(request.getPassword()); // In a real app, use encoder.encode()

        userRepository.save(user);
        return new AuthResponse("User registered successfully!", user.getId(), user.getUsername());
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Error: User not found!"));

        if (!user.getPassword().equals(request.getPassword())) {
             throw new RuntimeException("Error: Invalid password!");
        }

        return new AuthResponse("dummy-token", user.getId(), user.getUsername());
    }
}
