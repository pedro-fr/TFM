# TFM

## Descripción
Repositorio con código para la reproducibilidad del Trabajo de Fin de Máster sobre análisis de datos de secuenciación de ARN de células individuales (scRNA-seq).

## Estado del proyecto
🚧 En desarrollo activo

## Estructura del repositorio (propuesta inicial)
```
├── scripts/          # Scripts shell para procesamiento en cluster CESGA
├── notebooks/        # Análisis y visualización en R
├── data/            # Scripts de descarga y metadatos
├── results/         # Figuras y tablas principales
└── environment/     # Configuración y dependencias
```

## Pipeline de análisis
1. **Descarga de datos:** Scripts en `data/`
2. **Control de calidad:** FastQC, FastqScreen
3. **Procesamiento:** CellBender para eliminación de ruido
4. **Análisis:** Notebooks R para análisis downstream

## Herramientas principales
- CellBender
- FastQC
- FastqScreen
- R/Bioconductor

## Datos
Trabajamos con datos públicos de GEO (GSE206305).

---
Trabajo realizado en el cluster CESGA para procesamiento computacional intensivo.