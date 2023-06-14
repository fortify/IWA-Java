/*
        Insecure Web App (IWA)

        Copyright 2020-2023 Open Text or one of its affiliates.

        This program is free software: you can redistribute it and/or modify
        it under the terms of the GNU General Public License as published by
        the Free Software Foundation, either version 3 of the License, or
        (at your option) any later version.

        This program is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.

        You should have received a copy of the GNU General Public License
        along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package com.microfocus.example.config.handlers;

import com.microfocus.example.exception.ApiBadCredentialsException;
import com.microfocus.example.exception.ApiRefreshTokenException;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.annotation.AnnotationUtils;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import com.microfocus.example.exception.ServerErrorException;
import com.microfocus.example.exception.UserNotFoundException;
import com.microfocus.example.payload.response.ApiStatusResponse;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;

@ControllerAdvice
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    public static final String DEFAULT_ERROR_VIEW = "error/default";
    public static final String SERVER_ERROR_VIEW = "error/500-internal-error";

    @ExceptionHandler(ApiBadCredentialsException.class)
    public ResponseEntity<ApiStatusResponse> badCredentials(final ApiBadCredentialsException ex, final WebRequest request) {
        log.debug("GlobalExceptionHandler::badCredentials");
        ArrayList<String> errors = new ArrayList<>();
        errors.add(ex.getLocalizedMessage());
        final ApiStatusResponse apiStatusResponse = new ApiStatusResponse
                .ApiResponseBuilder()
                .withSuccess(false)
                .atTime(LocalDateTime.now(ZoneOffset.UTC))
                .withErrors(errors)
                .build();
        return new ResponseEntity<ApiStatusResponse>(apiStatusResponse, HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(ApiRefreshTokenException.class)
    public ResponseEntity<ApiStatusResponse> refreshToken(final ApiRefreshTokenException ex, final WebRequest request) {
        log.debug("GlobalExceptionHandler::refreshToken");
        ArrayList<String> errors = new ArrayList<>();
        errors.add(ex.getLocalizedMessage());
        final ApiStatusResponse apiStatusResponse = new ApiStatusResponse
                .ApiResponseBuilder()
                .withSuccess(false)
                .atTime(LocalDateTime.now(ZoneOffset.UTC))
                .withErrors(errors)
                .build();
        return new ResponseEntity<ApiStatusResponse>(apiStatusResponse, HttpStatus.NOT_FOUND);
    }

    @ExceptionHandler(ServerErrorException.class)
    public ModelAndView handleServerErrorException(final ServerErrorException ex, final HttpServletRequest request) {
    	log.error("error:" + ex.toString());
        ModelAndView mav = new ModelAndView();
        mav.addObject("exception", ExceptionUtils.getStackTrace(ex));
        mav.addObject("url", request.getRequestURL());
        mav.setViewName(SERVER_ERROR_VIEW);
        return mav;
    }

    @ExceptionHandler({Exception.class})
    public ModelAndView handleAll(HttpServletRequest request, final Exception ex) throws Exception {
        log.debug("GlobalExceptionHandler::handleAll");
        log.error("error:" + ex.toString());
        // If the exception is annotated with @ResponseStatus rethrow it and let
        // AnnotationUtils is a Spring Framework utility class.
        if (AnnotationUtils.findAnnotation
                (ex.getClass(), ResponseStatus.class) != null)
            throw ex;

        // Otherwise setup and send the user to a default error-view.
        ModelAndView mav = new ModelAndView();
        mav.addObject("exception", ExceptionUtils.getStackTrace(ex));
        mav.addObject("url", request.getRequestURL());
        mav.setViewName(DEFAULT_ERROR_VIEW);
        return mav;
    }

}
