#!/bin/bash
# Script de Backup Automatizado - Bootcamp AWS
# Descripción: Comprime datos de EBS/EFS y los sube a un Bucket S3.
# =================================================================

BUCKET_NAME="mi-bucket-de-respaldo-unico"   # Bucket creado en el lab
SOURCE_EFS="/mnt/shared"                    # Punto de montaje EFS
SOURCE_EBS="/mnt/logs"                      # Punto de montaje EBS
BACKUP_DIR="/tmp/backups"                   # Carpeta temporal local
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
FILE_NAME="backup_$TIMESTAMP.tar.gz"


mkdir -p $BACKUP_DIR
echo "--- Iniciando proceso de respaldo: $TIMESTAMP ---"

if [ -d "$SOURCE_EFS" ] && [ -d "$SOURCE_EBS" ]; then
    echo "[1/3] Comprimiendo archivos de EFS y EBS..."
    tar -czf $BACKUP_DIR/$FILE_NAME $SOURCE_EFS $SOURCE_EBS
else
    echo "ERROR: No se encontraron los puntos de montaje."
    exit 1
fi

echo "[2/3] Subiendo archivo a S3: s3://$BUCKET_NAME/"
aws s3 cp $BACKUP_DIR/$FILE_NAME s3://$BUCKET_NAME/

if [ $? -eq 0 ]; then 
    echo "[3/3] Respaldo completado exitosamente."
    rm $BACKUP_DIR/$FILE_NAME 
    echo "Limpieza local completada."
else 
    echo "ERROR: Falló la subida a S3. Revisa los permisos de IAM de la instancia."
    exit 1
fi

echo "--- Proceso finalizado ---"

