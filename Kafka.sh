#!/bin/bash

# ----------------------------
# Mini laboratorio Kafka WSL
# ----------------------------

#Crear red para contenedores
podman network inspect kafkanet >/dev/null 2>&1 || podman network create kafkanet
echo "Red kafkanet lista"

#Eliminar contenedor viejo si existe
podman rm -f kafkaserver >/dev/null 2>&1

#Levantar broker Kafka
echo "Levantando Kafka broker..."
podman run -d --name kafkaserver --net kafkanet -p 9092:9092 -p 9093:9093 \
  -e KAFKA_NODE_ID=1 \
  -e KAFKA_PROCESS_ROLES=broker,controller \
  -e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092,CONTROLLER://:9093 \
  -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 \
  -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT \
  -e KAFKA_CONTROLLER_QUORUM_VOTERS=1@kafkaserver:9093 \
  -e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER \
  -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
  -e KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1 \
  -e KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1 \
  docker.io/apache/kafka:4.1.0


#Espera a que Kafka arranque
echo "Esperando 10 segundos a que Kafka arranque..."
sleep 10

#Crear topic "test"
echo "Creando topic 'test'..."
podman exec kafkaserver /opt/kafka/bin/kafka-topics.sh \
  --create --topic test --bootstrap-server kafkaserver:9092 \
  --partitions 1 --replication-factor 1

#Instalar kafka-python si no está
pip show kafka-python >/dev/null 2>&1 || pip install kafka-python

#Crear Producer Python
cat <<EOF > producer.py
from kafka import KafkaProducer
producer = KafkaProducer(bootstrap_servers='localhost:9092')
for i in range(10):
    producer.send('test', f'Mensaje {i}'.encode('utf-8'))
producer.flush()
print("Mensajes enviados")
EOF

#Crear Consumer Python
cat <<EOF > consumer.py
from kafka import KafkaConsumer
consumer = KafkaConsumer('test', bootstrap_servers='localhost:9092', auto_offset_reset='earliest')
print("Consumer escuchando mensajes...")
for message in consumer:
    print(f"Recibido: {message.value.decode()}")
EOF

echo "Mini laboratorio listo"
echo "Para probar:"
echo "1 Abrir una terminal y ejecutar: python3 consumer.py"
echo "2 Abrir otra terminal y ejecutar: python3 producer.py"

