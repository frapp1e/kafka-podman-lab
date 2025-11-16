# kafka-podman-lab

Mini laboratorio de Apache Kafka utilizando Podman en WSL.

Este laboratorio demuestra cómo levantar un broker Kafka en un contenedor, crear un topic y enviar/recibir mensajes usando Python. Todo el proceso está automatizado mediante un script Bash para facilitar la ejecución y pruebas.

---

## Características

- Creación automática de red para contenedores (`kafkanet`).
- Levantamiento de un broker Kafka con Podman.
- Creación del topic `test`.
- Scripts en Python para:
  - **Producer**: envía mensajes al topic `test`.
  - **Consumer**: recibe mensajes en tiempo real desde el topic.
- Automatización completa con `kafka_lab_linkedin.sh`.

---

## Tecnologías utilizadas

- Apache Kafka
- Podman (contenedores)
- Python 3 (`kafka-python`)
- Bash
- WSL / Linux

---
