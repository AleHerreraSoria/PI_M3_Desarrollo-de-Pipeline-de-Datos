# Proyecto Integrador: Pipeline de Datos ELT en la Nube

## 1. Introducción y Contexto del Negocio

Este proyecto implementa un pipeline de datos completo siguiendo el paradigma  **ELT (Extract, Load, Transform)** , diseñado para una empresa en expansión que necesita una solución escalable para integrar y analizar grandes volúmenes de datos de múltiples fuentes. El objetivo es transformar datos crudos en conocimiento accionable para optimizar la toma de decisiones estratégicas.

Como prueba de concepto, el pipeline ingesta, procesa y analiza un dataset público de listados de  **Airbnb en Nueva York** , enriqueciéndolo con datos de tipo de cambio obtenidos de una API pública del  **Banco Central de la República Argentina (BCRA)** .

## 2. Arquitectura de la Solución

La arquitectura se construye sobre  **Google Cloud Platform (GCP)** , aprovechando sus servicios gestionados para garantizar escalabilidad, rendimiento y mantenibilidad.

### Tech Stack Utilizado

* **Proveedor Cloud:** Google Cloud Platform (GCP)
* **Data Lake / Staging:** Google Cloud Storage (GCS)
* **Data Warehouse:** Google BigQuery
* **Extracción de Datos:** Python, Docker
* **Orquestación de Pipeline:** Apache Airflow (desplegado con Docker Compose)
* **Control de Versiones y CI/CD:** Git, GitHub y GitHub Actions

## 3. Estructura del Repositorio

El proyecto está organizado de la siguiente manera para separar claramente cada componente:

```
PI_M3_Desarrollo de Pipeline de Datos/
│
├── .github/
│   └── workflows/
│       └── ci.yaml             # Flujo de CI con GitHub Actions
│
├── airflow/
│   ├── dags/
│   │   └── elt_pipeline_dag.py # DAG que orquesta la transformación
│   ├── logs/                   # (Ignorado por Git)
│   ├── plugins/
│   └── docker-compose.yaml     # Configuración para levantar Airflow
│
├── docs/
│   └── diseño_arquitectura.md  # Documento de diseño técnico
│
├── img/
│   └── arquitectura_cloud.png  # Diagrama de la arquitectura
│
├── src/
│   ├── Dockerfile              # Dockerfile para el script de extracción
│   ├── requirements.txt        # Dependencias del script de extracción
│   └── script_extract_bcra.py  # Script de extracción de datos del BCRA
│
├── .gitignore
├── README.md                   # Este archivo
└── requirements-dev.txt        # Dependencias para el entorno de CI

```

## 4. Componentes del Pipeline

### 4.1. Extracción (Extract)

Un script de Python (`src/script_extract_bcra.py`) se conecta a la API pública de Estadísticas Cambiarias del BCRA para obtener la última cotización del dólar. Este proceso incluye:

* **Validación de Calidad:** Verifica que los datos recibidos cumplan con un esquema esperado antes de ser procesados.
* **Carga en la Nube:** Sube el dato en formato JSON a un bucket en Google Cloud Storage, que actúa como nuestra capa `raw`.
* **Verificación de Carga:** Confirma que el archivo se ha subido correctamente al bucket.
* **Contenerización:** El script está empaquetado en una imagen de **Docker** para asegurar su portabilidad y ejecución consistente en cualquier entorno.

### 4.2. Carga (Load)

Los datos son cargados desde sus respectivas fuentes a la capa `raw` de nuestro Data Warehouse en  **Google BigQuery** :

* El dataset de Airbnb se carga manualmente desde un archivo CSV.
* Los datos del BCRA se cargan desde los archivos JSON en GCS.

### 4.3. Transformación (Transform)

Un script de **SQL** (`elt_pipeline_dag.py`) se ejecuta dentro de BigQuery para realizar todas las transformaciones. Este proceso crea dos capas adicionales en el DW:

* **Capa `transformed_data` (Plata):** Contiene una tabla (`listings_cleaned`) con los datos limpios, estandarizados y enriquecidos con el tipo de cambio en ARS.
* **Capa `business_layer` (Oro):** Contiene tablas agregadas y optimizadas que responden directamente a las preguntas de negocio.

### 4.4. Orquestación

**Apache Airflow** (desplegado localmente con Docker Compose) actúa como el orquestador central del pipeline.

* El DAG `elt_bigquery_pipeline` define el flujo de trabajo.
* Actualmente, orquesta la tarea de  **Transformación** , ejecutando el script SQL en BigQuery de forma programada (`@daily`) y garantizando la idempotencia mediante el uso de `CREATE OR REPLACE TABLE`.

## 5. CI/CD - Integración Continua

Se ha configurado un flujo de trabajo con **GitHub Actions** (`.github/workflows/ci.yaml`) que se activa automáticamente con cada `push` o `pull request` a la rama `main`. Este flujo de CI realiza una prueba de sintaxis sobre el código del DAG de Airflow para prevenir que errores básicos lleguen a producción.

## 6. Cómo Ejecutar el Proyecto

### Prerrequisitos

* Git
* Docker y Docker Compose
* Una cuenta de Google Cloud Platform con un proyecto y facturación habilitada.
* El SDK de Google Cloud (`gcloud`) configurado localmente (opcional, para gestión).

### Pasos para la Puesta en Marcha

1. **Clonar el Repositorio:**
   ```
   git clone [https://github.com/AleHerreraSoria/PI_M3_Desarrollo-de-Pipeline-de-Datos.git](https://github.com/AleHerreraSoria/PI_M3_Desarrollo-de-Pipeline-de-Datos.git)
   cd PI_M3_Desarrollo-de-Pipeline-de-Datos

   ```
2. **Configurar Credenciales de GCP:**
   * Sigue la guía de GCP para crear una cuenta de servicio con los roles: `Usuario de BigQuery`, `Editor de datos de BigQuery` y `Administrador de objetos de Storage`.
   * Descarga el archivo de credenciales JSON, renómbralo a `gcp_credentials.json` y colócalo dentro de la carpeta `src/`.
3. **Cargar Datos Iniciales en BigQuery:**
   * Crea los datasets `raw_data`, `transformed_data` y `business_layer` en tu proyecto de BigQuery.
   * Carga manualmente el archivo `AB_NYC.csv` en la tabla `raw_data.ab_nyc`.
4. **Ejecutar el Extractor de Datos:**
   * Navega a la carpeta `src/`.
   * Construye la imagen de Docker: `docker build -t bcra-extractor .`
   * Ejecuta el contenedor para subir el tipo de cambio a GCS: `docker run --rm -v "${pwd}/gcp_credentials.json:/app/gcp_credentials.json" bcra-extractor`
5. **Levantar Airflow:**
   * Navega a la carpeta `airflow/`.
   * Ejecuta: `docker compose up -d`
   * Accede a la UI en `http://localhost:8080` (user: `admin`, pass: `admin`).
6. **Configurar y Ejecutar el DAG:**
   * En la UI de Airflow, ve a `Admin > Connections` y crea una conexión `google_cloud_default` pegando el contenido de tu `gcp_credentials.json`.
   * Activa y ejecuta manualmente el DAG `elt_bigquery_pipeline`.

## 7. Preguntas de Negocio Resueltas

El pipeline genera las siguientes tablas en la capa `business_layer` para responder a preguntas estratégicas:

* **`avg_price_by_neighbourhood`** : ¿Cuál es el precio promedio de los alojamientos por barrio y distrito?
* **`room_type_analysis`** : ¿Qué tipo de habitación es el más ofrecido y cuál genera mayor revenue estimado?
* **`top_hosts_analysis`** : ¿Cuáles son los anfitriones con más propiedades listadas y cómo varían sus precios?
* **`reviews_evolution_by_month`** : ¿Cómo evoluciona el número de reseñas por mes en los diferentes distritos?

## 8. Autor

* www.linkedin.com/in/alejandro-nelson-herrera-soria
  https://github.com/AleHerreraSoria
