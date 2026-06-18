package com.example.uso_tic;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        TextView txtTitle = findViewById(R.id.txtTitle);
        Button btnTemas = findViewById(R.id.btnTemas);

        btnTemas.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v) {
                // Ir a la pantalla de temas
                Intent intent = new Intent(MainActivity.this, Temas.class);
                startActivity(intent);
            }
        });
    }


}