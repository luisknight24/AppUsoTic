package com.example.uso_tic;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import android.content.DialogInterface;
import android.os.Bundle;
import android.os.Handler;
import android.text.SpannableString;
import android.text.method.LinkMovementMethod;
import android.text.util.Linkify;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.GridLayout;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;

public class SopaDeLetrasIliada extends AppCompatActivity {
    private String[] palabras = {"LAILIADA", "HOMERO", "TROYA", "ZEUZ", "ARTEMISA"};
    private int palabrasEncontradas = 0;
    private GridLayout gridSopaDeLetras;
    private List<Button> buttonList;
    private List<Button> palabraSeleccionada;
    private TextView tvPuntajeObtenido;
    private int puntaje = 0;

    private Set<String> palabrasContabilizadas = new HashSet<>();

    private Set<Button> letrasSubrayadas = new HashSet<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sopa_de_letras_iliada);

        tvPuntajeObtenido = findViewById(R.id.tvPuntajeObtenido); // Agrega esta línea

        gridSopaDeLetras = findViewById(R.id.gridSopaDeLetras);
        Button btnReiniciar = findViewById(R.id.btnReiniciar);
        Button btnInstrucciones = findViewById(R.id.btnInstrucciones);
        Button btnRegresar = findViewById(R.id.btnRegresar);

        inicializarSopaDeLetras();

        btnReiniciar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                reiniciarJuego();
            }
        });

        btnInstrucciones.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mostrarInstrucciones();
            }
        });

        btnRegresar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                regresarAActividadAnterior();
            }
        });
    }

    private void inicializarSopaDeLetras() {
        // Asegurémonos de que las palabras se coloquen entre letras aleatorias
        List<String> listaPalabras = new ArrayList<>();
        Collections.addAll(listaPalabras, palabras);
        Collections.shuffle(listaPalabras);

        gridSopaDeLetras.removeAllViews();
        buttonList = new ArrayList<>();
        palabraSeleccionada = new ArrayList<>();

        // Crear una sopa de letras fija
        char[][] sopaDeLetras = new char[12][12];
        for (int i = 0; i < 12; i++) {
            for (int j = 0; j < 12; j++) {
                sopaDeLetras[i][j] = '-';
            }
        }

        // Colocar las palabras en la sopa de letras
        for (String palabra : listaPalabras) {
            colocarPalabra(sopaDeLetras, palabra);
        }

        // Rellenar el espacio restante con letras aleatorias
        for (int i = 0; i < 12; i++) {
            for (int j = 0; j < 12; j++) {
                Button btnLetra = new Button(this);

                //// Ajusta el tamaño de los botones
                int widthPixels = (int) getResources().getDimension(R.dimen.button_width);
                int heightPixels = (int) getResources().getDimension(R.dimen.button_height);

                btnLetra.setLayoutParams(new GridLayout.LayoutParams(
                        new ViewGroup.LayoutParams(widthPixels, heightPixels)));

                if (sopaDeLetras[i][j] == '-') {
                    // Si es un espacio vacío, colocar letra aleatoria
                    btnLetra.setText(obtenerLetraAleatoria());
                } else {
                    // Si es parte de una palabra, configurar con la letra de la palabra
                    btnLetra.setText(String.valueOf(sopaDeLetras[i][j]));
                }

                // Configuración de las etiquetas
                btnLetra.setTag(R.id.letraFila, i);
                btnLetra.setTag(R.id.letraColumna, j);

                // Fondo personalizado
                btnLetra.setBackgroundResource(R.drawable.boton_background);

                btnLetra.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        manejarSeleccionLetra(btnLetra);
                    }
                });

                buttonList.add(btnLetra);
                gridSopaDeLetras.addView(btnLetra);
            }
        }
    }

    private void colocarPalabra(char[][] sopaDeLetras, String palabra) {
        Random random = new Random();
        int fila, columna;
        boolean colocada = false;

        while (!colocada) {
            boolean esHorizontal = random.nextBoolean();
            if (esHorizontal) {
                fila = random.nextInt(12);
                columna = random.nextInt(12 - palabra.length() + 1);
            } else {
                fila = random.nextInt(12 - palabra.length() + 1);
                columna = random.nextInt(12);
            }

            if (esHorizontal && palabraPuedeColocarseHorizontal(sopaDeLetras, palabra, fila, columna)) {
                colocarPalabraHorizontal(sopaDeLetras, palabra, fila, columna);
                colocada = true;
            } else if (!esHorizontal && palabraPuedeColocarseVertical(sopaDeLetras, palabra, fila, columna)) {
                colocarPalabraVertical(sopaDeLetras, palabra, fila, columna);
                colocada = true;
            }
        }
    }

    private boolean palabraPuedeColocarseHorizontal(char[][] sopaDeLetras, String palabra, int fila, int columna) {
        for (int i = 0; i < palabra.length(); i++) {
            if (sopaDeLetras[fila][columna + i] != '-' && sopaDeLetras[fila][columna + i] != palabra.charAt(i)) {
                return false;
            }
        }
        return true;
    }

    private void colocarPalabraHorizontal(char[][] sopaDeLetras, String palabra, int fila, int columna) {
        for (int i = 0; i < palabra.length(); i++) {
            sopaDeLetras[fila][columna + i] = palabra.charAt(i);
        }
    }

    private boolean palabraPuedeColocarseVertical(char[][] sopaDeLetras, String palabra, int fila, int columna) {
        for (int i = 0; i < palabra.length(); i++) {
            if (sopaDeLetras[fila + i][columna] != '-' && sopaDeLetras[fila + i][columna] != palabra.charAt(i)) {
                return false;
            }
        }
        return true;
    }

    private void colocarPalabraVertical(char[][] sopaDeLetras, String palabra, int fila, int columna) {
        for (int i = 0; i < palabra.length(); i++) {
            sopaDeLetras[fila + i][columna] = palabra.charAt(i);
        }
    }

    private String obtenerLetraAleatoria() {
        Random random = new Random();
        char letra = (char) (random.nextInt(26) + 'A');
        return String.valueOf(letra);
    }

    private void manejarSeleccionLetra(Button btnLetra) {
        // Verificamos si la letra es adyacente a la última letra seleccionada
        if (esAdyacente(btnLetra)) {
            palabraSeleccionada.add(btnLetra);
            subrayarPalabraEnFormacion();
        } else {
            reiniciarSeleccion();
            palabraSeleccionada.add(btnLetra);
            subrayarPalabraEnFormacion();
        }
    }

    private boolean esAdyacente(Button btnLetra) {
        if (!palabraSeleccionada.isEmpty()) {
            Button ultimaLetra = palabraSeleccionada.get(palabraSeleccionada.size() - 1);
            int filaUltima = (int) ultimaLetra.getTag(R.id.letraFila);
            int columnaUltima = (int) ultimaLetra.getTag(R.id.letraColumna);
            int filaActual = (int) btnLetra.getTag(R.id.letraFila);
            int columnaActual = (int) btnLetra.getTag(R.id.letraColumna);

            return Math.abs(filaUltima - filaActual) <= 1 && Math.abs(columnaUltima - columnaActual) <= 1;
        }
        return true;
    }

    private void subrayarPalabraEnFormacion() {
        StringBuilder palabraActual = new StringBuilder();
        for (Button btnLetra : palabraSeleccionada) {
            palabraActual.append(btnLetra.getText());
        }

        if (esPalabraValidaEnFormacion(palabraActual.toString())) {
            // Si la secuencia actual forma parte de una palabra válida, subrayamos
            for (Button btnLetra : palabraSeleccionada) {
                btnLetra.setBackgroundColor(getResources().getColor(android.R.color.holo_blue_light));
            }
            // Comprobamos si la palabra actual es una de las palabras válidas
            if (esPalabraValida(palabraActual.toString())) {
                palabraEncontrada();
            }
        } else {
            // Si la secuencia no forma parte de una palabra válida, reiniciamos la selección
            reiniciarSeleccion();
        }
    }

    // Método para verificar si la palabra actual es válida
    private boolean esPalabraValida(String palabraActual) {
        for (String p : palabras) {
            if (p.equals(palabraActual)) {
                return true;
            }
        }
        return false;
    }

    private boolean esPalabraValidaEnFormacion(String palabra) {
        for (String p : palabras) {
            if (p.startsWith(palabra)) {
                return true;
            }
        }
        return false;
    }

    private void reiniciarSeleccion() {
        for (Button btnLetra : buttonList) {
            btnLetra.setBackgroundResource(R.drawable.boton_background);
        }
        palabraSeleccionada.clear();
    }

    private void reiniciarJuego() {
        palabrasEncontradas = 0; // Restablece las palabras a 0
        puntaje = 0; // Restablece el puntaje a cero
        tvPuntajeObtenido.setText("Puntaje obtenido: 0/10"); // Actualiza el TextView del puntaje
        reiniciarSeleccion();
        palabrasContabilizadas.clear();
        inicializarSopaDeLetras();
    }

    private void palabraEncontrada() {
        if (!palabraSeleccionada.isEmpty()) {
            // Obtener la palabra actual
            StringBuilder palabraActual = new StringBuilder();
            for (Button btnLetra : palabraSeleccionada) {
                palabraActual.append(btnLetra.getText());
            }

            // Verificar si la palabra ya ha sido contabilizada
            if (!palabrasContabilizadas.contains(palabraActual.toString())) {
                palabrasContabilizadas.add(palabraActual.toString());

                // Solo si la palabra no ha sido contabilizada previamente
                palabrasEncontradas++;
                puntaje += 2; // Aumentar el puntaje en 2 puntos

                tvPuntajeObtenido.setText("Puntaje obtenido: " + puntaje + "/10"); // Actualizar el TextView del puntaje

                if (palabrasEncontradas == palabras.length) {
                    mostrarDialogoFinJuego(); // Muestra el diálogo al completar todas las palabras
                }
            }
        }
    }

    private void mostrarDialogoFinJuego() {
        // Crear el cuadro de diálogo
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("¡Felicidades!");
        builder.setMessage("¡Has completado el juego!");

        // Agregar botones Reintentar y Regresar
        builder.setPositiveButton("Reintentar", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                reiniciarJuego();
            }
        });

        builder.setNegativeButton("Regresar", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                // Regresa a la pantalla anterior
                finish();
            }
        });

        // Mostrar el cuadro de diálogo
        builder.create().show();
    }

    public void mostrarInstrucciones() {
        // Crear un cuadro de diálogo para mostrar las instrucciones
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Instrucciones para Jugar");

        // Se define el contenido del cuadro de diálogo con instrucciones
        TextView textView = new TextView(this);
        textView.setText(obtenerInstrucciones());
        textView.setAutoLinkMask(Linkify.ALL);
        textView.setMovementMethod(LinkMovementMethod.getInstance());

        // Agregar márgenes al cuadro de texto (en píxeles)
        int marginPixels = (int) getResources().getDimension(R.dimen.instrucciones_margin);
        textView.setPadding(marginPixels, marginPixels, marginPixels, marginPixels);

        builder.setView(textView);

        // Se agrega un botón "Regresar" al cuadro de diálogo
        builder.setPositiveButton("Regresar", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
            }
        });

        // Mostrar el cuadro de diálogo
        builder.create().show();
    }

    // Función para obtener las instrucciones formateadas
    private SpannableString obtenerInstrucciones() {
        String instrucciones = "1. Para seleccionar una palabra, presione de cuadro en cuadro y en orden las letras correspondientes de dicha palabra.\n" +
                "2. Cada palabra encontrada será contabilizada solo una vez.\n" +
                "3. Cada palabra sumará dos puntos hasta completar un total de 10.\n";

        return new SpannableString(instrucciones);
    }

    public void regresarAActividadAnterior() {
        //Regresa a la pantalla anterior
        finish();
    }
}