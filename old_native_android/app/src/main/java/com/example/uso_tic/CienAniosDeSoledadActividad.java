package com.example.uso_tic;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import com.example.uso_tic.AhorcadoCienAños.MainGameActivityCien;
import com.example.uso_tic.AhorcadoCienAños.WelcomeCienActivity;
import com.example.uso_tic.hangman.WelcomeActivity;

public class CienAniosDeSoledadActividad extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_cien_anios_de_soledad_actividad);

        // Método para redireccionar hacia el juego del ahorcado sobre el tema de Cien años de soledad
        Button btnAhorcado = findViewById(R.id.btnAhorcadoCienAnios);
        btnAhorcado.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(CienAniosDeSoledadActividad.this, WelcomeCienActivity.class);
                startActivity(intent);
            }
        });

        Button btnRegresar = findViewById(R.id.btnRegresarCienAnios);
        btnRegresar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Regresar a la pantalla general de Cien años de soledad
                finish();
            }
        });
    }
}