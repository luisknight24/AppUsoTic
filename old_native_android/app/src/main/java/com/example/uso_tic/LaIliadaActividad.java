package com.example.uso_tic;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class LaIliadaActividad extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_iliada_actividad);


        // Redireccionar hacia la sopa de letras sobre el tema de la Iliada
        Button btnSopaDeLetras = findViewById(R.id.btnSopaLetras);
        btnSopaDeLetras.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(LaIliadaActividad.this, SopaDeLetrasIliada.class);
                startActivity(intent);
            }
        });

        Button btnRegresar = findViewById(R.id.btnRegresar);
        btnRegresar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Regresar a la pantalla general de la Iliada
                finish();
            }
        });
    }
}