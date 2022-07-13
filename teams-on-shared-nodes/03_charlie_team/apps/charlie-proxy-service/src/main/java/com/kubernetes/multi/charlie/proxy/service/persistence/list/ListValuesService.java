package com.kubernetes.multi.charlie.proxy.service.persistence.list;

import com.fasterxml.jackson.core.type.TypeReference;
import com.kubernetes.multi.charlie.proxy.dto.ResponseDto;
import com.kubernetes.multi.charlie.proxy.service.persistence.entity.Value;
import com.kubernetes.multi.charlie.proxy.service.persistence.list.dto.ListValuesResponseDto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.lang.reflect.ParameterizedType;
import java.util.ArrayList;
import java.util.List;

@Service
public class ListValuesService {

    private final Logger logger = LoggerFactory.getLogger(ListValuesService.class);

    @Autowired
    private RestTemplate restTemplate;

    public ListValuesService() {}

    public ResponseEntity<ResponseDto<ListValuesResponseDto>> run() {
        var model = new ResponseDto<ListValuesResponseDto>();

        logger.info("Retrieving values from persistence service...");

        var responseDtoFromPersistenceService = makeRequestToPersistenceService();

        var statusCode = responseDtoFromPersistenceService.getStatusCode();
        logger.info("Status code: " + statusCode);
        logger.info("Message: " + responseDtoFromPersistenceService.getBody().getMessage());

        if (statusCode == HttpStatus.OK) {

            var responseDto = new ListValuesResponseDto();
            responseDto.setValues(new ArrayList<>());

            responseDto.getValues().addAll(responseDtoFromPersistenceService.getBody().getData());

            model.setMessage("Values are retrieved successfully.");
            model.setStatusCode(HttpStatus.OK);
            model.setData(responseDto);
        }
        else {
            model.setMessage("Values are failed to be retrieved.");
            model.setStatusCode(HttpStatus.INTERNAL_SERVER_ERROR);
        }

        logger.info("Values are retrieved successfully from persistence service.");

        return new ResponseEntity<>(model, statusCode);
    }

    private ResponseEntity<ResponseDto<List<Value>>> makeRequestToPersistenceService() {
        var url = "http://persistence.charlie.svc.cluster.local:8080/persistence/list";

        return restTemplate.exchange(url, HttpMethod.GET, null,
                new ParameterizedTypeReference<>() {});
    }
}
