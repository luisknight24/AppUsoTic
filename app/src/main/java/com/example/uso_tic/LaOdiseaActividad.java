package com.example.uso_tic;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import com.example.uso_tic.hangman.WelcomeActivity;

public class LaOdiseaActividad extends AppCompatActivity {
    private WelcomeActivity welcomeActivity;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_odisea_actividad);


        // Método para redireccionar hacia el juego del ahorcado sobre el tema de la Odisea
        Button btnAhorcado = findViewById(R.id.btnAhorcadoOdisea);
        btnAhorcado.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(LaOdiseaActividad.this,  WelcomeActivity.class);
                startActivity(intent);
            }
        });

        Button btnRegresar = findViewById(R.id.btnRegresarOdisea);
        btnRegresar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Regresar a la pantalla general de la Odisea
                finish();
            }
        });
    }
}