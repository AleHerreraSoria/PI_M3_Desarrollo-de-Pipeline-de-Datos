# 🚀 Proyecto Integrador: Pipeline de Datos ELT en la Nube

## 1. Introducción y Contexto del Negocio

Este proyecto implementa un pipeline de datos completo siguiendo el paradigma  **ELT (Extract, Load, Transform)** , diseñado para una empresa en expansión que necesita una solución escalable para integrar y analizar grandes volúmenes de datos de múltiples fuentes. El objetivo es transformar datos crudos en conocimiento accionable para optimizar la toma de decisiones estratégicas.

Como prueba de concepto, el pipeline ingesta, procesa, analiza y visualiza un dataset público de listados de  **Airbnb en Nueva York** , enriqueciéndolo con datos de tipo de cambio obtenidos de una API pública del  **Banco Central de la República Argentina (BCRA)** .

## 2. Arquitectura de la Solución ⚙️

La arquitectura se construye íntegramente sobre  **Google Cloud Platform (GCP)** , aprovechando sus servicios gestionados para garantizar escalabilidad, rendimiento y mantenibilidad.

### Tech Stack Utilizado

| **Componente**          | **Tecnología**       | **Propósito**                          |
| ----------------------------- | --------------------------- | --------------------------------------------- |
| **Proveedor Cloud**     | Google Cloud Platform (GCP) | Infraestructura escalable y gestionada.       |
| **Data Lake / Staging** | Google Cloud Storage (GCS)  | Almacenamiento de objetos crudos.             |
| **Data Warehouse**      | Google BigQuery             | Almacenamiento y procesamiento de datos.      |
| **Extracción**         | Python & Docker             | Script para obtener datos de la API del BCRA. |
| **Orquestación**       | Apache Airflow              | Automatización y programación del pipeline. |
| **CI/CD**               | GitHub & GitHub Actions     | Control de versiones y pruebas automatizadas. |
| **Visualización**      | Jupyter Notebook & Seaborn  | Análisis y visualización de resultados.     |

## 3. Estructura del Repositorio

El proyecto está organizado de la siguiente manera para separar claramente cada componente:

```
PI_M3_Desarrollo de Pipeline de Datos/
│
├── .github/
│   └── workflows/
│       └── ci.yaml               # Flujo de CI con GitHub Actions
│
├── airflow/
│   ├── dags/
│   │   └── elt_pipeline_dag.py # DAG que orquesta la transformación
│   └── docker-compose.yaml       # Configuración para levantar Airflow
│
├── docs/
│   └── diseño_arquitectura.md  # Documento de diseño técnico
│
├── img/
│   └── arquitectura_cloud.png  # Diagrama de la arquitectura
│
├── src/
│   ├── Dockerfile                # Dockerfile para el script de extracción
│   ├── requirements.txt          # Dependencias del script de extracción
│   ├── script_extract_bcra.py    # Script de extracción de datos del BCRA
│   ├── requirements-viz.txt      # Dependencias para el notebook
│   └── visualizacion_negocio.ipynb # Notebook de visualización
│
├── .gitignore
├── README.md                   # Este archivo
└── requirements-dev.txt        # Dependencias para el entorno de CI

```

## 4. Componentes del Pipeline

### 4.1. Extracción (Extract) 📥

Un script de Python (`src/script_extract_bcra.py`) se conecta a la API pública de Estadísticas Cambiarias del BCRA para obtener la última cotización del dólar. Este proceso incluye:

* **Validación de Calidad:** Verifica que los datos recibidos cumplan con un esquema esperado.
* **Carga en la Nube:** Sube el dato en formato JSON a un bucket en GCS (nuestra capa `raw`).
* **Verificación de Carga:** Confirma que el archivo se ha subido correctamente.
* **Contenerización:** El script está empaquetado en una imagen de **Docker** (`anhsoria/bcra-extractor:1.0`) publicada en Docker Hub, asegurando su portabilidad.

### 4.2. Carga (Load) ➡️

Los datos son cargados desde sus fuentes a la capa `raw_data` de nuestro Data Warehouse en  **Google BigQuery** :

* El dataset de Airbnb se carga manualmente desde `AB_NYC.csv`, especificando el esquema y omitiendo el encabezado para garantizar la integridad.
* Los datos del BCRA se cargan desde los archivos JSON en GCS.

### 4.3. Transformación (Transform) ✨

Un script de **SQL** se ejecuta dentro de BigQuery para realizar todas las transformaciones. Este proceso crea dos capas adicionales en el DW:

* **Capa `transformed_data` (Plata):** Contiene una tabla (`listings_cleaned`) con los datos limpios, estandarizados y enriquecidos con el tipo de cambio en ARS.
* **Capa `business_layer` (Oro):** Contiene tablas agregadas y optimizadas que responden directamente a las preguntas de negocio.

### 4.4. Orquestación 🎵

**Apache Airflow** (desplegado localmente con Docker Compose) actúa como el orquestador central del pipeline.

* El DAG `elt_pipeline_dag.py` define el flujo de trabajo.
* Este DAG orquesta la tarea de  **Transformación** , ejecutando el script SQL en BigQuery de forma programada (`@daily`) y garantizando la idempotencia mediante el uso de `CREATE OR REPLACE TABLE`. Se optó por esta solución robusta y funcional que cumple con los objetivos del proyecto.

### 4.5. Visualización (Analyze) 📊

Un **Jupyter Notebook** (`src/visualizacion_negocio.ipynb`) se conecta directamente a la capa `business_layer` en BigQuery para:

* Extraer los datos ya procesados y agregados.
* Utilizar librerías como `pandas`, `matplotlib` y `seaborn` para generar visualizaciones claras.
* Presentar las respuestas a las preguntas de negocio de forma gráfica e intuitiva.

## 5. CI/CD - Integración Continua 🔄

Se ha configurado un flujo de trabajo con **GitHub Actions** (`.github/workflows/ci.yaml`) que se activa automáticamente con cada `push` o `pull request`. Este flujo de CI realiza una prueba de sintaxis sobre el código del DAG de Airflow para prevenir que errores básicos lleguen a producción.

## 6. Cómo Ejecutar el Proyecto

### Prerrequisitos

* Git
* Docker y Docker Compose
* Una cuenta de Google Cloud Platform con un proyecto y facturación habilitada.

### Pasos para la Puesta en Marcha

1. **Clonar el Repositorio:**
   ```
   git clone [https://github.com/AleHerreraSoria/PI_M3_Desarrollo-de-Pipeline-de-Datos.git](https://github.com/AleHerreraSoria/PI_M3_Desarrollo-de-Pipeline-de-Datos.git)
   cd PI_M3_Desarrollo-de-Pipeline-de-Datos

   ```
