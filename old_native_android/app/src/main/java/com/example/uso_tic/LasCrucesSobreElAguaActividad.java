package com.example.uso_tic;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import com.example.uso_tic.AhorcadoCruces.WelcomeActivityCruces;

public class LasCrucesSobreElAguaActividad extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_las_cruces_sobre_el_agua_actividad);

        // Método para redireccionar hacia el crucigrama que referencia al tema de Las cruces sobre el agua
        Button btnCrucigrama = findViewById(R.id.btnCrucigramaCruces);
        btnCrucigrama.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(LasCrucesSobreElAguaActividad.this, WelcomeActivityCruces.class);
                startActivity(intent);
            }
        });

        Button btnRegresar = findViewById(R.id.btnRegresarCruces);
        btnRegresar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Regresar a la pantalla general de Las cruces sobre el agua
                finish();
            }
        });
    }
}