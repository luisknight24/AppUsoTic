package com.example.uso_tic;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import androidx.appcompat.app.AppCompatActivity;

public class Temas extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_temas);

        // Array de temas
        final String[] temas = {"La Iliada", "La Odisea", "Las cruces sobre el agua", "Cien años de soledad", "Eneida"};

        // Crear dinámicamente botones para cada tema
        for (int i = 0; i < temas.length; i++) {
            int buttonId = getResources().getIdentifier("btnTema" + (i + 1), "id", getPackageName());
            Button button = findViewById(buttonId);
            button.setText(temas[i]);
            final int finalI = i; // Variable final para uso en el Listener
            button.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    // Lógica al hacer clic en un tema
                    abrirPantallaTema(temas[finalI]);
                }
            });
        }
    }

    private void abrirPantallaTema(String tema) {
        // Determinar qué pantalla de tema abrir según el tema seleccionado
        if (tema.equals("La Iliada")) {
            Intent intent = new Intent(Temas.this, LaIliada.class);
            startActivity(intent);
        } else if (tema.equals("La Odisea")) {
            Intent intent = new Intent(Temas.this, LaOdisea.class);
            startActivity(intent);
        } else if (tema.equals("Las cruces sobre el agua")) {
            Intent intent = new Intent(Temas.this, LasCrucesSobreElAgua.class);
            startActivity(intent);
        } else if (tema.equals("Cien años de soledad")) {
            Intent intent = new Intent(Temas.this, CienAniosDeSoledad.class);
            startActivity(intent);
        } else if (tema.equals("Eneida")) {
            Intent intent = new Intent(Temas.this, Eneida.class);
            startActivity(intent);
        }
    }
}