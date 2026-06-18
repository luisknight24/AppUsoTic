package com.example.uso_tic.AhorcadoCruces;

import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TableRow;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import com.example.uso_tic.AhorcadoCienAños.EndGameActivtyCien;
import com.example.uso_tic.AhorcadoCienAños.MainGameActivityCien;
import com.example.uso_tic.AhorcadoCienAños.ScoreCounterCien;
import com.example.uso_tic.AhorcadoCienAños.WordManagerCien;
import com.example.uso_tic.AhorcadoCienAños.WordProviderCien;
import com.example.uso_tic.R;
import com.example.uso_tic.Temas;
import com.example.uso_tic.hangman.HangmanVisualizer;
import com.example.uso_tic.hangman.TextViewFactory;

import java.util.HashSet;
import java.util.Set;

public class MainGameActivityCruces extends AppCompatActivity {

    private Set<String> usedWords = new HashSet<>();
    private TableRow myTableRow;
    private WordProviderCruces wordProvider;
    private EditText etInputChar;
    private TextView labelIncorrectChars;
    TextView textView3;
    int palabrasAcertadas;
    private HangmanVisualizer hangmanVisualizer;
    private final int MAX_ALLOWED_GUESSES = 9;
    private final WordManagerCruces manager = new WordManagerCruces();
    private final ScoreCounterCruces scoreCounter = new ScoreCounterCruces(this);
    private TextView wordRepresentationTextView;

    private static final int END_GAME_REQUEST_CODE = 1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main_game_crucesa);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_NOSENSOR);

        textView3 = findViewById(R.id.textView3);
        textView3.setText("Puntaje: " + palabrasAcertadas + "/10");

        etInputChar = findViewById(R.id.etInput);
        labelIncorrectChars = findViewById(R.id.labelIncorrectEntries);
        labelIncorrectChars.setText("_");

        wordRepresentationTextView = findViewById(R.id.wordRepresentationTextView);
        ImageView imgHangman = findViewById(R.id.imageView14);
        hangmanVisualizer = new HangmanVisualizer(imgHangman);

        wordProvider = new WordProviderCruces();
        fillTableRow(wordProvider);
    }

    private void resetUsedWords() {
        usedWords.clear();
    }

    private void resetGame() {
        myTableRow.removeAllViews();
        resetUsedWords();
        hangmanVisualizer.resetHangman();
        fillTableRow(wordProvider);
    }

    private static final int MAX_WORDS_TO_PLAY = 10;
    private int wordsPlayedCount = 0;

    private void fillTableRow(WordProviderCruces wordProvider) {
        TextViewFactory factory = new TextViewFactory(this);
        myTableRow = findViewById(R.id.myTableRow);
        myTableRow.removeAllViews();

        if (wordsPlayedCount < MAX_WORDS_TO_PLAY) {
            String randomWord = wordProvider.getNextAvailableWord();

            if (randomWord != null) {
                manager.setSearchWord(randomWord);
                usedWords.add(randomWord);

                for (int i = 0; i < randomWord.length(); i++) {
                    myTableRow.addView(factory.createTextView(i));
                }

                wordsPlayedCount++;
                textView3.setText("Puntaje: " + palabrasAcertadas + "/10");
            } else {
                // Todas las palabras han sido utilizadas después de reiniciar.
                showEndGameDialog();
                wordsPlayedCount = 0;
            }
        } else {
            showEndGameDialog();
            wordsPlayedCount = 0;
        }
    }

    private void showEndGameDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);

        mostrarDialogoFinJuego(builder);

        AlertDialog dialog = builder.create();
        dialog.show();
    }

    private void mostrarDialogoFinJuego(AlertDialog.Builder builder) {
        builder.setTitle("¡Haz completado el juego!");
        builder.setMessage("Tu puntuación fue: " + palabrasAcertadas + "/10");

        //Botones Reintentar y Regresar
        builder.setPositiveButton("Reintentar", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                resetGame();
                palabrasAcertadas=0;
            }
        });

        builder.setNegativeButton("Regresar", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                // Regresa a la pantalla anterior o realiza alguna acción
                finish();
            }
        });
    }

    public void continueToNextWord(View view) {
        resetGame();
    }

    public void addChar(View view) {
        String input = etInputChar.getText().toString().toLowerCase();
        etInputChar.setText("");

        if (TextUtils.isEmpty(input) || !manager.isGuessedCharAllowed(input.charAt(0))) {
            showToast(R.string.input_illegal_char);
            return;
        }

        char insertedChar = input.charAt(0);
        String insertedCharStr = String.valueOf(insertedChar);
        if (manager.getGuessedChars().contains(insertedCharStr)) {
            showToast(R.string.input_guessed_char);
            return;
        }

        if (manager.getWrongEstimatedChars().contains(insertedCharStr)) {
            showToast(R.string.input_unsuccessful_guessed);
            return;
        }

        boolean isSuccessfullyFound = false;
        for (int i = 0; i < manager.getSearchWord().length(); i++) {
            if (manager.getSearchWord().charAt(i) == insertedChar) {
                displayGuessedChar(insertedChar, i);
                isSuccessfullyFound = true;
            }
        }

        if (!isSuccessfullyFound) {
            manager.addWrongEstimatedCharsChar(insertedChar);
            updateHangman();
            updateMisGuessedLabels();
        } else {
            manager.addGuessedChar(insertedChar);
            scoreCounter.incrementScore();  // Incrementa el puntaje solo si la palabra se adivina correctamente
        }

        textView3.setText("Puntaje: " + palabrasAcertadas + "/10");

        if (manager.getNoDuplicateGuessedChars().toArray().length == manager.getGuessedChars().length()) {
            endGame(true);
        }
    }

    private void updateHangman() {
        int wrongGuesses = Integer.parseInt(manager.getWrongEstimatedChars());
        hangmanVisualizer.updateHangmanImage(wrongGuesses);

        if (wrongGuesses >= MAX_ALLOWED_GUESSES) {
            endGame(false);
        }
    }

    private void showToast(int messageId) {
        Toast.makeText(getApplicationContext(), getResources().getString(messageId), Toast.LENGTH_LONG).show();
    }

    private void displayGuessedChar(char insertedChar, int index) {
        TextView textView = (TextView) myTableRow.getVirtualChildAt(index);
        textView.setText(String.valueOf(insertedChar));
    }

    private void updateMisGuessedLabels() {
        labelIncorrectChars.setText(manager.getWrongEstimatedChars());
    }

    private void endGame(boolean win) {
        if (win) {
            palabrasAcertadas++;
        }

        Intent endGame = new Intent(this, EndGameActivityCruces.class);
        endGame.putExtra("isWin", win);
        endGame.putExtra("score", palabrasAcertadas);  // Envia la puntuación sobre 10
        endGame.putExtra("word", manager.getSearchWord());
        startActivityForResult(endGame, END_GAME_REQUEST_CODE);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == END_GAME_REQUEST_CODE && resultCode == RESULT_OK) {
            boolean continueGame = data.getBooleanExtra("continue", false);
            if (continueGame) {
                resetGame();
                manager.resetIncorrectAttempts();
                updateMisGuessedLabels();
            }
        }
    }
}
