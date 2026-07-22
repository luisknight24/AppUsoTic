package com.example.uso_tic;

import androidx.appcompat.app.AppCompatActivity;

import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.MediaController;
import android.widget.Toast;
import android.widget.VideoView;

public class LaOdiseaVideo extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_la_odisea_video);

        // Obtener el VideoView
        VideoView videoView = findViewById(R.id.videoView);

        // Obtener la ruta del archivo de video desde la carpeta 'raw'
        String filePath = "android.resource://" + getPackageName() + "/raw/laodisea";

        try {
            // Configurar el VideoView
            videoView.setVideoURI(Uri.parse(filePath));

            // Configurar el controlador de medios para el VideoView
            MediaController mediaController = new MediaController(this);
            mediaController.setAnchorView(videoView);
            videoView.setMediaController(mediaController);

            // Iniciar la reproducción del video
            videoView.start();
        } catch (Exception e) {
            // Manejo de excepciones
            Toast.makeText(this, "Error al reproducir el video: " + e.getMessage(), Toast.LENGTH_SHORT).show();
        }

        // Botón Regresar
        Button btnRegresarVideo = findViewById(R.id.btnRegresarVideo);
        btnRegresarVideo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Regresar a la pantalla principal de La Odisea
                finish();
            }
        });
    }
}