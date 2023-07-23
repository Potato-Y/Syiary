package io.potatoy.syiary.token.entity;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import io.potatoy.syiary.token.entity.RefreshToken;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {
    Optional<RefreshToken> findByUserId(Long userId);

    Optional<RefreshToken> findByRefreshToken(String refreshToken);
}
