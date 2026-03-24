package com.app.smartTaskManager.controller;

import com.app.smartTaskManager.models.User;
import com.app.smartTaskManager.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class UserController {
        @Autowired
    UserService userService;
        //for registration
        @PostMapping("/register")
    public User register(@Valid @RequestBody User user){
            return userService.register(user);
        }
        //for login
    @PostMapping("/login")
    public String login(@RequestParam String email,@RequestParam String password){
            return userService.login(email,password);
    }

}
