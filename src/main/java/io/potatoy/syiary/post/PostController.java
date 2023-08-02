package io.potatoy.syiary.post;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import io.potatoy.syiary.post.dto.CreatePostRequest;
import io.potatoy.syiary.post.dto.CreatePostResponse;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/groups")
public class PostController {

    private final PostService postService;

    @PostMapping("/{groupUri}/posts")
    public ResponseEntity<CreatePostResponse> createPost(
            @PathVariable String groupUri,
            @Validated @ModelAttribute CreatePostRequest request) throws Exception {

        CreatePostResponse response = postService.createPost(groupUri, request);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}
