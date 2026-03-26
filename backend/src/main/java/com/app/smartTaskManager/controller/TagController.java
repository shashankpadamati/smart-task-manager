package com.app.smartTaskManager.controller;

import com.app.smartTaskManager.repository.TagRepository;
import com.app.smartTaskManager.security.services.UserDetailsImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/tags")
@RequiredArgsConstructor
public class TagController {

    private final TagRepository tagRepository;

    @GetMapping
    public List<String> getUserTags(@AuthenticationPrincipal UserDetailsImpl currentUser) {
        return tagRepository.findAllByUserId(currentUser.getId())
                .stream()
                .map(tag -> tag.getName())
                .collect(Collectors.toList());
    }
}
