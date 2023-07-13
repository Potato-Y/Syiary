package io.potatoy.syiary.controller;

import io.potatoy.syiary.domain.User;
import io.potatoy.syiary.dto.user.AddUserRequest;
import io.potatoy.syiary.dto.user.AddUserResponse;
import io.potatoy.syiary.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api")
public class UserApiController {
    private final UserService userService;

    @PostMapping("/user")
    public ResponseEntity signup(@RequestBody AddUserRequest request) {
        User user = userService.save(request); // 회원가입 메서드 호출

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new AddUserResponse(user.getId(), user.getEmail()));
    }
}
