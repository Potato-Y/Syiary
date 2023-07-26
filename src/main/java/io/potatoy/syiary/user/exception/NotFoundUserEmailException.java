package io.potatoy.syiary.user.exception;

public class NotFoundUserEmailException extends RuntimeException {

    public NotFoundUserEmailException(String message) {
        super(message);
    }
}
