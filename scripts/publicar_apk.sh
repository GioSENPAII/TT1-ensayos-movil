#!/usr/bin/env bash
# Compila el APK de Android para la nube y lo publica en el bucket público de descargas.
#
# Uso, desde ensayos_movil/:   ./scripts/publicar_apk.sh
# Antes de publicar una versión nueva, sube "version:" en pubspec.yaml (p. ej. 1.0.1+2): Android solo
# instala una actualización encima de la anterior si el número después de "+" es mayor.
#
# Requiere la llave de firma en ../llaves/key.properties (respaldo en Secret Manager:
# ensayos-apk-keystore y ensayos-apk-key-properties).
set -euo pipefail
cd "$(dirname "$0")/.."

API_URL=https://ensayos-backend-990972460164.northamerica-south1.run.app/api/v1
BUCKET=aplicacion-desarrollo-descargas
HUELLA=b76c9f4828151799a0c9d36d4324890301c984f9e0edb4b635754c622b892ba9   # SHA-256 del certificado
APK=build/app/outputs/flutter-apk/app-release.apk
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)

[ -f ../llaves/key.properties ] || { echo "Falta ../llaves/key.properties (llave de firma)"; exit 1; }

echo "==> Compilando versión $VERSION (ARM, apunta a la nube)"
flutter build apk --release --target-platform android-arm,android-arm64 --dart-define=API_URL=$API_URL

# Un APK firmado con otra llave no se puede instalar encima del anterior
APKSIGNER=$(ls -d "$HOME"/Library/Android/sdk/build-tools/* | tail -1)/apksigner
"$APKSIGNER" verify --print-certs "$APK" | grep -qi "SHA-256 digest: $HUELLA" \
  || { echo "El APK no está firmado con la llave de publicación"; exit 1; }

echo "==> Publicando en gs://$BUCKET"
gcloud storage cp "$APK" "gs://$BUCKET/ensayos-movil-$VERSION.apk" \
  --content-type=application/vnd.android.package-archive
# El nombre fijo es el que enlaza la web; no-cache para que siempre se descargue la última versión
gcloud storage cp "$APK" "gs://$BUCKET/ensayos-movil.apk" \
  --content-type=application/vnd.android.package-archive --cache-control=no-cache

echo "==> Listo: https://storage.googleapis.com/$BUCKET/ensayos-movil.apk  (versión $VERSION)"
