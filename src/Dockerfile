# --- Etapa 1: Definir la imagen base ---
# Usamos una imagen oficial de Python que es liviana ('slim').
# Esto hace que nuestra imagen final sea más pequeña y eficiente.
FROM python:3.10-slim

# --- Etapa 2: Configurar el entorno de trabajo ---
# Establecemos el directorio de trabajo dentro del contenedor.
# Todos los comandos siguientes se ejecutarán desde esta ruta.
WORKDIR /app

# --- Etapa 3: Instalar dependencias ---
# Copiamos primero el archivo de requerimientos.
# Esto aprovecha el sistema de caché de Docker: si este archivo no cambia,
# no se volverán a instalar las dependencias en futuras construcciones.
COPY requirements.txt .

# Instalamos las librerías listadas en requirements.txt.
# --no-cache-dir evita guardar la caché de pip, reduciendo el tamaño de la imagen.
RUN pip install --no-cache-dir -r requirements.txt

# --- Etapa 4: Copiar el código de la aplicación ---
# Copiamos nuestro script de extracción al directorio de trabajo del contenedor.
COPY script_extract_bcra.py .

# --- Etapa 5: Definir el comando de ejecución ---
# Especificamos el comando que se ejecutará cuando el contenedor se inicie.
# Esto correrá nuestro script de Python.
ENTRYPOINT ["python", "script_extract_bcra.py"]