package com.example.uso_tic;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class EneidaActividad extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_eneida_actividad);

        // Método para redireccionar hacia el crucigrama sobre el tema de Eneida
        Button btnCrucigrama = findViewById(R.id.btnCrucigramaEneida);
        btnCrucigrama.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(EneidaActividad.this, SopaDeLetrasEneida.class);
                startActivity(intent);
            }
        });

        Button btnRegresar = findViewById(R.id.btnRegresarEneida);
        btnRegresar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Regresar a la pantalla general de La Eneida
                finish();
            }
        });
    }
}