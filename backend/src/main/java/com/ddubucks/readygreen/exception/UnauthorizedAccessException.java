package com.ddubucks.readygreen.exception;

public class UnauthorizedAccessException extends RuntimeException {
    public UnauthorizedAccessException(String unauthorizedAccess) {
        super(unauthorizedAccess);
    }
}
