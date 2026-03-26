package com.app.smartTaskManager.service;

import com.app.smartTaskManager.dto.request.LoginRequest;
import com.app.smartTaskManager.dto.request.SignupRequest;
import com.app.smartTaskManager.dto.response.AuthResponse;

public interface AuthService {
    AuthResponse signup(SignupRequest request);
    AuthResponse login(LoginRequest request);
}
