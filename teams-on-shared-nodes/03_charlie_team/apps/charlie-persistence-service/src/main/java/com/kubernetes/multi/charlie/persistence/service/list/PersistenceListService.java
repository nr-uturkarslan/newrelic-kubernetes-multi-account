package com.kubernetes.multi.charlie.persistence.service.list;

import com.kubernetes.multi.charlie.persistence.dto.ResponseDto;
import com.kubernetes.multi.charlie.persistence.entities.Value;
import com.kubernetes.multi.charlie.persistence.repositories.ValueRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PersistenceListService {

    private final Logger logger = LoggerFactory.getLogger(PersistenceListService.class);

    @Autowired
    private ValueRepository valueRepository;

    public PersistenceListService() {}

    public ResponseEntity<ResponseDto<List<Value>>> run() {
        logger.info("Retrieving all values...");

        var allValues = valueRepository.findAll();

        logger.info("All values are retrieved successfully.");

        var responseDto = new ResponseDto<List<Value>>();
        responseDto.setMessage("All values are retrieved successfully.");
        responseDto.setStatusCode(HttpStatus.OK.value());
        responseDto.setData(allValues);

        return new ResponseEntity<>(responseDto, HttpStatus.OK);
    }
}
