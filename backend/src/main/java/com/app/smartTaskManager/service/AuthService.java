package com.app.smartTaskManager.service;

import com.app.smartTaskManager.dto.request.LoginRequest;
import com.app.smartTaskManager.dto.request.SignupRequest;
import com.app.smartTaskManager.dto.response.AuthResponse;
import com.app.smartTaskManager.models.User;
import com.app.smartTaskManager.repository.UserRepository;
import com.app.smartTaskManager.security.jwt.JwtUtils;
import com.app.smartTaskManager.security.services.UserDetailsImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;

    public AuthResponse signup(SignupRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Error: Email is already in use!");
        }

        // Create new user account and encrypt the password
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));

        userRepository.save(user);

        // Auto login after signup
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword()));

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtUtils.generateJwtToken(authentication);

        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();

        return new AuthResponse(jwt, userDetails.getId(), userDetails.getUsername());
    }

    public AuthResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword()));

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtUtils.generateJwtToken(authentication);

        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();

        return new AuthResponse(jwt, userDetails.getId(), userDetails.getUsername());
    }

    public AuthResponse refreshToken(String refreshToken) {
        if (refreshToken != null && jwtUtils.validateJwtToken(refreshToken)) {
            String email = jwtUtils.getEmailFromJwtToken(refreshToken);
            
            User user = userRepository.findByEmail(email)
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            String newJwt = jwtUtils.generateTokenFromEmail(email);
            return new AuthResponse(newJwt, user.getId(), user.getUsername());
        }
        throw new RuntimeException("Invalid Refresh Token");
    }
}
