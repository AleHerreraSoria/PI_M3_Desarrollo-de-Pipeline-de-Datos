-- Script para crear una tabla externa que lee los JSON del BCRA desde GCS

CREATE OR REPLACE EXTERNAL TABLE `eng-name-468100-g3.raw_data.bcra_exchange_rates`
(
  fecha STRING,
  moneda STRING,
  descripcion STRING,
  valor_venta FLOAT64
)
OPTIONS (
  format = 'JSON', -- O 'JSONL' si guardaste cada JSON en una línea
  uris = ['gs://bucket-pi-m3-anhs/raw/*']
);