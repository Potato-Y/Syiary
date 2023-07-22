package io.potatoy.syiary.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import io.potatoy.syiary.dto.group.CreateGroupRequest;
import io.potatoy.syiary.dto.group.CreateGroupResponse;
import io.potatoy.syiary.dto.group.DeleteGroupRequest;
import io.potatoy.syiary.service.GroupService;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api")
public class GroupController {

    private final GroupService groupService;

    @PostMapping("/group") // 그룹 생성
    public ResponseEntity<CreateGroupResponse> groupCreate(@Validated @RequestBody CreateGroupRequest request) {

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(groupService.createGroup(request));
    }

    // @DeleteMapping("/group") // 그룹 삭제
    // public ResponseEntity<String> groupDelete(@Validated @RequestBody
    // DeleteGroupRequest request) {
    // return ResponseEntity.status(HttpStatus.OK)
    // .body("null");
    // }
}
