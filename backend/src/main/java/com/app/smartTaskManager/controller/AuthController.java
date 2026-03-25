package com.app.smartTaskManager.controller;

import com.app.smartTaskManager.dto.request.LoginRequest;
import com.app.smartTaskManager.dto.request.SignupRequest;
import com.app.smartTaskManager.dto.response.AuthResponse;
import com.app.smartTaskManager.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    // POST /api/auth/signup
    // Body: { "username": "john", "email": "john@example.com", "password":
    // "pass123" }
    // Response: { "token": "eyJ...", "type": "Bearer", "userId": 1, "username":
    // "john" }
    @PostMapping("/signup")
    public ResponseEntity<AuthResponse> signup(@Valid @RequestBody SignupRequest request) {
        AuthResponse response = authService.signup(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    // POST /api/auth/login
    // Body: { "email": "john@example.com", "password": "pass123" }
    // Response: { "token": "eyJ...", "type": "Bearer", "userId": 1, "username":
    // "john" }
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    // POST /api/auth/logout
    // Header: Authorization: Bearer <token>
    // Stateless JWT — client should discard the token. Optionally blacklist
    // server-side.
    @PostMapping("/logout")
    public ResponseEntity<String> logout() {
        // With stateless JWT, logout is handled on the client side.
        // If you maintain a token blacklist, call authService.logout(token) here.
        return ResponseEntity.ok("Logged out successfully");
    }

    // POST /api/auth/refresh
    // Body: { "refreshToken": "eyJ..." }
    // Response: { "token": "eyJ...", "type": "Bearer", ... }
    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refreshToken(@RequestBody String refreshToken) {
        AuthResponse response = authService.refreshToken(refreshToken);
        return ResponseEntity.ok(response);
    }
}