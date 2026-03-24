package com.app.smartTaskManager.service;

import com.app.smartTaskManager.models.User;
import com.app.smartTaskManager.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserService {
    @Autowired
    UserRepository repo;
    //logic for rigistering
    public User register(User user){
        if(repo.existsByEmail(user.getEmail())){
            throw new RuntimeException("email already present");
        }
        return repo.save(user);
    }
    public String login(String email,String password){
        Optional<User>userOpt = repo.findByEmail(email);
        if(userOpt.isEmpty()){
            throw new RuntimeException("User not found");
        }
        User user = userOpt.get();
        if(!user.getPassword().equals(password)){
            throw new RuntimeException("Invalid password");
        }
        return "Login successfully";
    }
}
