package io.potatoy.syiary.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
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

    @PostMapping("/groups") // 그룹 생성
    public ResponseEntity<CreateGroupResponse> groupCreate(@Validated @RequestBody CreateGroupRequest request) {

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(groupService.createGroup(request));
    }

    @DeleteMapping("/groups/{groupUri}") // 그룹 삭제
    public ResponseEntity<String> groupDelete(@PathVariable String groupUri,
            @Validated @RequestBody DeleteGroupRequest request) {
        groupService.deleteGroup(groupUri, request);

        return ResponseEntity.status(HttpStatus.NO_CONTENT).body(null);
    }
}
