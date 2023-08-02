package io.potatoy.syiary.post;

import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import io.potatoy.syiary.group.entity.Group;
import io.potatoy.syiary.group.entity.GroupRepository;
import io.potatoy.syiary.post.dto.CreatePostRequest;
import io.potatoy.syiary.post.dto.CreatePostResponse;
import io.potatoy.syiary.post.entity.Post;
import io.potatoy.syiary.post.entity.PostFile;
import io.potatoy.syiary.post.entity.PostFileRepository;
import io.potatoy.syiary.post.entity.PostRepository;
import io.potatoy.syiary.post.handler.FileHandler;
import io.potatoy.syiary.security.util.SecurityUtil;
import io.potatoy.syiary.user.entity.User;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class PostService {

    private final Logger logger = LogManager.getLogger(PostService.class);
    private final GroupRepository groupRepository;
    private final PostRepository postRepository;
    private final PostFileRepository postFileRepository;
    private final FileHandler fileHandler;
    private final SecurityUtil securityUtil;

    public CreatePostResponse createPost(String postUri, CreatePostRequest dto) throws Exception {
        User user = securityUtil.getCurrentUser();
        Group group = groupRepository.findById(dto.getGroupId()).get();

        logger.info("createPost. userId={}, groupId={}", user.getId(), group.getId());

        Post post = Post.builder()
                .group(group)
                .user(user)
                .content(dto.getContent())
                .build();

        postRepository.save(post);

        List<PostFile> postFiles = fileHandler.parseFileInfo(user, group, post, dto.getFiles());

        post.updateFile(postFiles);

        postFileRepository.saveAll(postFiles);

        return new CreatePostResponse(post.getId(), post.getContent());
    }
}
