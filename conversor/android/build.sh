#!/usr/bin/env bash
# Compila el APK del conversor con las herramientas oficiales del Android SDK (sin Gradle).
# Uso:   ANDROID_HOME=/ruta/al/sdk bash conversor/android/build.sh
# Requiere: JDK 17, "platforms;android-34" y "build-tools;34.0.0" instalados en el SDK.
# Firma: con KEYSTORE, KS_PASS y KS_ALIAS usa esa clave; si faltan, crea una clave nueva
# (en ese caso, para actualizar la app en el teléfono hay que desinstalar la versión anterior).
set -euo pipefail

AQUI="$(cd "$(dirname "$0")" && pwd)"
WEB="$(dirname "$AQUI")"
OUT="$AQUI/build"
: "${ANDROID_HOME:?Defina ANDROID_HOME con la ruta del Android SDK}"
BT="$ANDROID_HOME/build-tools/${BUILD_TOOLS:-34.0.0}"
JAR="$ANDROID_HOME/platforms/android-34/android.jar"
VERSION=$(sed -n 's/.*android:versionName="\([^"]*\)".*/\1/p' "$AQUI/AndroidManifest.xml")
APK="$OUT/conversor-mmol-mgdl-$VERSION.apk"

rm -rf "$OUT"
mkdir -p "$OUT/obj" "$OUT/assets/www/fonts"

echo "1/4 Página web dentro del APK"
cp "$WEB/index.html" "$WEB/icon.svg" "$OUT/assets/www/"
cp "$WEB"/fonts/*.woff2 "$WEB"/fonts/*.txt "$OUT/assets/www/fonts/"

echo "2/4 Código Java → DEX"
javac -source 8 -target 8 -bootclasspath "$JAR" -Xlint:-options -encoding UTF-8 -d "$OUT/obj" $(find "$AQUI/src" -name '*.java')
"$BT/d8" --release --lib "$JAR" --min-api 24 --output "$OUT" $(find "$OUT/obj" -name '*.class')

echo "3/4 Recursos, manifiesto y empaquetado"
"$BT/aapt2" compile --dir "$AQUI/res" -o "$OUT/res.zip"
"$BT/aapt2" link -o "$OUT/sin-firma.apk" -I "$JAR" --manifest "$AQUI/AndroidManifest.xml" -A "$OUT/assets" "$OUT/res.zip"
(cd "$OUT" && zip -q sin-firma.apk classes.dex)
"$BT/zipalign" -f -p 4 "$OUT/sin-firma.apk" "$OUT/alineado.apk"

echo "4/4 Firma y verificación"
if [ -z "${KEYSTORE:-}" ]; then
  KEYSTORE="$OUT/clave.jks"; KS_PASS="${KS_PASS:-conversor}"; KS_ALIAS="${KS_ALIAS:-conversor}"
  keytool -genkeypair -keystore "$KEYSTORE" -storepass "$KS_PASS" -keypass "$KS_PASS" -alias "$KS_ALIAS" \
    -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Conversor mmol/L - mg/dL, O=Uso personal, C=CO" >/dev/null
fi
"$BT/apksigner" sign --ks "$KEYSTORE" --ks-pass "pass:$KS_PASS" --ks-key-alias "$KS_ALIAS" --out "$APK" "$OUT/alineado.apk"
"$BT/apksigner" verify --verbose "$APK" | grep -E '^Verifies|scheme'
"$BT/aapt2" dump badging "$APK" | grep -E "^package|sdkVersion|application-label:|launchable-activity|uses-permission" || true
unzip -l "$APK" | tail -n +4 | awk '{print $4}' | grep -E '^(assets|classes|AndroidManifest)'
echo "APK listo: $APK ($(du -h "$APK" | cut -f1))"
