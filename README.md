# Calculadora de Infusiones IV

Calculadora web de infusiones intravenosas para cuidado crítico y hospitalización: mL/h de infusiones continuas, bolos y cargas, mezclas de referencia, soluciones compatibles, tabla de titulación, lista de infusiones del paciente y el paso a paso de cada cálculo.

**Autor:** Dr. William Ricardo Castañeda Vargas — Médico · Mg. Epidemiología · Esp. IA.

**Fuentes principales:** Soto Muñoz L. *Dosis, diluciones e infusiones en paciente crítico y emergencias*, v1.0.3 (2022), y Castañeda Vargas WR. *Infusiones intravenosas: guía para aprender y entenderlas sin dolor* (HRVT, 2025). Las fuentes externas de cada medicamento agregado aparecen en la propia página.

> Herramienta de apoyo. No reemplaza la prescripción médica, el criterio clínico, el protocolo institucional ni el doble chequeo de enfermería.

La página es un único archivo HTML sin dependencias de servidor; funciona sin conexión después de la primera visita.

## Conversor mmol/L ↔ mg/dL

La carpeta [`conversor/`](conversor/) contiene una segunda aplicación instalable e independiente: convierte resultados de laboratorio entre mmol/L, µmol/L, mEq/L, mg/dL, µg/dL y g/L para glucosa, lactato, β-hidroxibutirato, creatinina, urea y BUN, ácido úrico, colesterol, triglicéridos, sodio, potasio, cloro, calcio, magnesio, fósforo, bilirrubina, amonio, hierro y etanol, o para cualquier sustancia con su peso molecular. Cada factor se calcula con el peso molecular (mg/dL = mmol/L × PM ÷ 10) y la página muestra el paso a paso.

**Fuentes:** Young, D. S. (1987). Implementation of SI units for clinical laboratory data. *Annals of Internal Medicine, 106*(1), 114–129. https://doi.org/10.7326/0003-4819-106-1-114 · Prohaska, T., et al. (2022). Standard atomic weights of the elements 2021 (IUPAC Technical Report). *Pure and Applied Chemistry, 94*(5), 573–600. https://doi.org/10.1515/pac-2019-0603

Para instalarla en el teléfono, abra `…/conversor/` en el navegador y elija «Agregar a la pantalla de inicio» (Android: Chrome; iPhone: Safari → Compartir).

**Uso sin conexión.** En la primera visita con internet, el service worker guarda en el equipo toda la aplicación, incluidas las fuentes tipográficas, que van dentro de `conversor/fonts/` (Atkinson Hyperlegible e IBM Plex Mono, licencia SIL OFL 1.1). La página no pide nada a servidores externos. Desde ese momento abre y calcula sin internet; el aviso del encabezado indica «Lista para usar sin conexión». Siempre abre primero la copia guardada y, si hay conexión, la actualiza en segundo plano para la siguiente apertura. Al publicar cambios, suba la versión de `CACHE` en `conversor/sw.js`.

### App de Android (sin internet ni para instalarla)

`conversor/android/` contiene una app nativa mínima: un WebView que abre el conversor desde los archivos del propio APK (`file:///android_asset/www/`). No pide permisos, no usa internet y no tiene service worker. El flujo [`APK del conversor`](.github/workflows/apk-conversor.yml) la compila en GitHub con el Android SDK oficial (`aapt2`, `d8`, `zipalign`, `apksigner`, sin Gradle) cada vez que cambia `conversor/`, y publica el instalador en **Releases** como `conversor-mmol-mgdl-<versión>.apk`.

Instalación en el teléfono (Android 7.0 o superior):

1. Descargue el `.apk` desde Releases y páselo al teléfono por cable USB, WhatsApp, correo o memoria.
2. Ábralo desde el administrador de archivos. Android pedirá permitir «instalar apps desconocidas» a esa aplicación; acéptelo una sola vez.
3. Si Play Protect advierte que no reconoce la app, elija «Instalar de todas formas» (o «Más detalles» → «Instalar de todas formas»).
4. El ícono «mmol ↔ mg» queda en el cajón de aplicaciones y abre sin conexión.

Para publicar una versión nueva, aumente `android:versionCode` y `android:versionName` en `conversor/android/AndroidManifest.xml`. Si el repositorio no tiene el secreto `APK_KEYSTORE_B64` (con `APK_KEYSTORE_PASS` y `APK_KEY_ALIAS`), cada compilación se firma con una clave nueva y, para actualizar, hay que desinstalar la versión anterior antes de instalar la nueva; la app solo guarda la última sustancia elegida, así que no se pierde nada importante.
