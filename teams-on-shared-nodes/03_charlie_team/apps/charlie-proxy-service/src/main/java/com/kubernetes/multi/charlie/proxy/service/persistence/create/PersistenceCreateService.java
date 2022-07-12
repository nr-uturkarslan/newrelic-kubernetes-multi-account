package com.kubernetes.multi.charlie.proxy.service.persistence.create;

import com.kubernetes.multi.charlie.proxy.common.NewRelicTracer;
import com.kubernetes.multi.charlie.proxy.dto.ResponseDto;
import com.newrelic.api.agent.Trace;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
public class PersistenceCreateService {

    private final String TOPIC = "charlie";
    private final Logger logger = LoggerFactory.getLogger(PersistenceCreateService.class);

    @Autowired
    private KafkaProducer<String, String> producer;

    @Autowired
    private NewRelicTracer newRelicTracer;

    public PersistenceCreateService() {}

    @Trace(dispatcher = true)
    public ResponseEntity<ResponseDto<CreateRequestDto>> run(
        CreateRequestDto requestDto
    )
    {
        // Create Kafka producer record
        var record = createProducerRecord(requestDto);

        // Send record to topic
        producer.send(record, (recordMetadata, e) -> {
            if (e == null)
                logger.info("Record is successfully sent to topic.");
            else
                logger.error("Record is failed to be sent to topic: "
                    + e.getMessage());
        });

        producer.flush();

        return createResponseDto(requestDto);
    }

    private ProducerRecord<String, String> createProducerRecord(
        CreateRequestDto requestDto
    ) {
        var record = new ProducerRecord<>(
            TOPIC,
            requestDto.getTag(),
            requestDto.getValue()
        );

        newRelicTracer.track(record);

        return record;
    }

    private ResponseEntity<ResponseDto<CreateRequestDto>> createResponseDto(
        CreateRequestDto requestDto
    ) {
        logger.info("Request is successfully processed.");

        var responseDto = new ResponseDto<CreateRequestDto>();

        responseDto.setMessage("Value is created successfully.");
        responseDto.setStatusCode(HttpStatus.CREATED);
        responseDto.setData(requestDto);

        return new ResponseEntity<>(responseDto, responseDto.getStatusCode());
    }
}
