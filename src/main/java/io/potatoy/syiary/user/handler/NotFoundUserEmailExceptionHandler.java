package io.potatoy.syiary.user.handler;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import io.potatoy.syiary.error.dto.ErrorResponse;
import io.potatoy.syiary.user.exception.NotFoundUserEmailException;
import io.potatoy.syiary.util.EnvProperties;

@RestControllerAdvice
public class NotFoundUserEmailExceptionHandler {

    public static final String PROD = "prod";

    private final EnvProperties envProperties;

    public NotFoundUserEmailExceptionHandler(EnvProperties envProperties) {
        this.envProperties = envProperties;
    }

    @ExceptionHandler(NotFoundUserEmailException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleNotFoundUserEmailExceptionHandler(NotFoundUserEmailException exception) {
        if (envProperties.getMode().equals(PROD)) { // 운영 환경에서는 상세 내용을 반환하지 않도록 설정
            return new ErrorResponse(HttpStatus.NOT_FOUND.value(), null);
        }

        return new ErrorResponse(HttpStatus.NOT_FOUND.value(), exception.toString());
    }

}
