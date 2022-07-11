package com.kubernetes.multi.charlie.persistence.service.create;

import com.kubernetes.multi.charlie.persistence.common.NewRelicTracer;
import com.kubernetes.multi.charlie.persistence.config.Constants;
import com.newrelic.api.agent.Trace;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;

public class PersistenceCreateService {

    private final Logger logger = LoggerFactory.getLogger(PersistenceCreateService.class);

    @Autowired
    private NewRelicTracer newRelicTracer;

    @Trace(dispatcher = true)
    @KafkaListener(topics = Constants.TOPIC, groupId = Constants.GROUP_ID)
    public void listen(
            ConsumerRecord<String, String> record
    )
    {
        newRelicTracer.track(record);

        logger.info("Message tag  : " + record.key());
        logger.info("Message value: " + record.value());
    }
}
