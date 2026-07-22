package com.example.uso_tic;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.view.View;
import android.widget.Button;
import android.widget.MediaController;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.FileProvider;

import android.widget.VideoView;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;


public class LaIliada extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_la_iliada);

        // Botón Video
        Button btnVideo = findViewById(R.id.btnVideo);
        btnVideo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Lógica para redirigir a la vista del video sobre la Iliada
                abrirVistaVideo();
            }
        });

        // Botón PDF
        Button btnPDF = findViewById(R.id.btnPDF);
        btnPDF.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Lógica para abrir PDF de La Iliada
                abrirPDF("LA_ILIADA.pdf");
            }
        });

        // Botón Actividad
        Button btnActividad = findViewById(R.id.btnActividad);
        btnActividad.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Ir a la pantalla de actividad de La Iliada
                Intent intent = new Intent(LaIliada.this, LaIliadaActividad.class);
                startActivity(intent);
            }
        });

        // Botón Regresar
        Button btnRegresar = findViewById(R.id.btnRegresar);
        btnRegresar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Regresar a la pantalla de Temas
                finish();
            }
        });

    }

    //Método para abrir la vista del video
    private void abrirVistaVideo() {
        Intent intent = new Intent(LaIliada.this, LaIliadaVideo.class);
        startActivity(intent);
    }

    //Método para abrir el pdf
    private void abrirPDF(String fileName) {
        try {
            // Obtener la ruta del archivo PDF en la carpeta 'assets'
            String assetFilePath = "file:///android_asset/" + fileName;

            // Copiar el archivo PDF a un directorio temporal
            InputStream assetInputStream = getAssets().open(fileName);
            File tempFile = File.createTempFile("temp", "pdf", getCacheDir());
            FileOutputStream tempOutputStream = new FileOutputStream(tempFile);

            byte[] buffer = new byte[1024];
            int read;
            while ((read = assetInputStream.read(buffer)) != -1) {
                tempOutputStream.write(buffer, 0, read);
            }

            assetInputStream.close();
            tempOutputStream.flush();
            tempOutputStream.close();

            // Obtener la URI del archivo temporal
            Uri uri = FileProvider.getUriForFile(this, getApplicationContext().getPackageName() + ".provider", tempFile);

            // Crear una intención para abrir el archivo PDF
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setDataAndType(uri, "application/pdf");
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

            // Intentar abrir el visor de PDF
            startActivity(intent);
        } catch (Exception e) {
            // Manejar excepciones (puede no haber una aplicación para abrir PDF)
            Toast.makeText(this, "No se pudo abrir el PDF. Error: " + e.getMessage(), Toast.LENGTH_SHORT).show();
        }
    }
}
