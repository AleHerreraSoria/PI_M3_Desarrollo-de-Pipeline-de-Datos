    # Usar la imagen oficial de Airflow como base
    FROM apache/airflow:2.8.0

    # Cambiar al usuario root para instalar paquetes
    USER root

    # Instalar el cliente de Docker
    RUN apt-get update && \
        apt-get install -y docker.io && \
        apt-get clean

    # Añadir el usuario 'airflow' al grupo 'docker' para darle permisos
    RUN usermod -aG docker airflow

    # Volver al usuario airflow
    USER airflow