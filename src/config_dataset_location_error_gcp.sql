    -- #############################################################################
    -- SCRIPT DE CONFIGURACIÓN DE DATASETS (Infraestructura como Código)
    -- #############################################################################

    -- Elimina los datasets si ya existen para asegurar un inicio limpio.
    DROP SCHEMA IF EXISTS `eng-name-468100-g3.raw_data` CASCADE;
    DROP SCHEMA IF EXISTS `eng-name-468100-g3.transformed_data` CASCADE;
    DROP SCHEMA IF EXISTS `eng-name-468100-g3.business_layer` CASCADE;

    -- Crea los nuevos datasets especificando la ubicación correcta.
    -- Esto soluciona el error de "location".
    CREATE SCHEMA `eng-name-468100-g3.raw_data`
    OPTIONS(
      location = 'US'
    );

    CREATE SCHEMA `eng-name-468100-g3.transformed_data`
    OPTIONS(
      location = 'US'
    );

    CREATE SCHEMA `eng-name-468100-g3.business_layer`
    OPTIONS(
      location = 'US'
    );
