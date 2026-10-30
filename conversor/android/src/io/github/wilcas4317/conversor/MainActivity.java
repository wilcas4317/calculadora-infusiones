package io.github.wilcas4317.conversor;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

/**
 * Muestra el conversor que viaja dentro del APK (assets/www) en un WebView.
 * Todo se lee del propio teléfono: la aplicación no necesita internet ni para instalarse ni para abrirse.
 */
public class MainActivity extends Activity {
    private static final String INICIO = "file:///android_asset/www/index.html";
    private WebView web;

    @Override
    protected void onCreate(Bundle estado) {
        super.onCreate(estado);
        web = new WebView(this);
        WebSettings ajustes = web.getSettings();
        ajustes.setJavaScriptEnabled(true);
        ajustes.setDomStorageEnabled(true); // recuerda la última sustancia elegida
        web.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView vista, String url) {
                if (url.startsWith("file:///android_asset/")) return false;
                // Enlaces externos (DOI de las fuentes): se abren en el navegador del teléfono, si hay conexión
                try {
                    startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url)));
                } catch (ActivityNotFoundException e) {
                    // Ninguna aplicación puede abrir el enlace: se ignora
                }
                return true;
            }
        });
        setContentView(web);
        if (estado == null || web.restoreState(estado) == null) web.loadUrl(INICIO);
    }

    @Override
    protected void onSaveInstanceState(Bundle salida) {
        super.onSaveInstanceState(salida);
        web.saveState(salida);
    }

    @Override
    protected void onDestroy() {
        web.destroy();
        super.onDestroy();
    }
}
