package io.potatoy.syiary.post.util;

import org.springframework.stereotype.Component;

import io.potatoy.syiary.group.entity.Group;
import io.potatoy.syiary.group.util.GroupUtil;
import io.potatoy.syiary.post.entity.Post;
import io.potatoy.syiary.user.entity.User;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Component
public class PostUtil {

    private final GroupUtil groupUtil;

    /**
     * post에 대한 권한을 확인 있을 경우 true를 반환
     * 작성자만 권한을 갖는다.
     * 
     * @param group
     * @param user
     * @return
     */
    public boolean checkFixAuthority(User user, Group group, Post post) {
        Long reqUserId = user.getId(); // 요청자 user id
        Long writerId = post.getUser().getId(); // 작성자 user id

        groupUtil.checkGroupUser(user, group); // 사용자가 그룹에 포함되어 있는지 확인

        // 작성자 본인인지 확인
        if (reqUserId.equals(writerId)) {
            return true;
        }

        // 작성자가 아닌 경우 false 반환
        return false;
    }
}
