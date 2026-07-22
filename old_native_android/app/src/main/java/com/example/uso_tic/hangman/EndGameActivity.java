package com.example.uso_tic.hangman;
import static java.lang.String.*;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;

import android.content.DialogInterface;
import android.media.MediaPlayer;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.graphics.drawable.AnimationDrawable;
import android.os.Bundle;
import android.view.ContextThemeWrapper;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.example.uso_tic.MainActivity;
import com.example.uso_tic.R;
import com.example.uso_tic.Temas;

import java.util.Objects;
public class EndGameActivity extends AppCompatActivity {


    TextView labelWord;
    TextView labelScore;
    int lastScore;
    boolean win;
    String word = null;
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_NOSENSOR); // Desactivar rotación de pantalla.
        setContentView(R.layout.activity_end_game);

        labelWord = findViewById(R.id.labelWord);
        labelScore = findViewById(R.id.labelScore);
        Button continueButton = findViewById(R.id.continueButton);
        continueButton.setOnClickListener(this::continueToNextWord);
        Intent intent = getIntent();
        lastScore = intent.getIntExtra("score", 0);
        labelScore.setText(valueOf(lastScore));
        win = intent.getBooleanExtra("isWin", false);
        word = Objects.requireNonNull(intent.getStringExtra("word")).toUpperCase();

        labelWord.setText(word.toUpperCase());
        initAnimation();
    }

    private void initAnimation()  //Segunda manera de crear una animación.
    {
        AnimationDrawable anim = new AnimationDrawable();
        ImageView image = findViewById(R.id.image);
        MediaPlayer mp;

        if (!win)
        {
            mp = MediaPlayer.create(this, R.raw.loosegame);
            mp.start();

            anim.addFrame(Objects.requireNonNull(ContextCompat.getDrawable(this, R.drawable.e1)), 1500);
            anim.addFrame(Objects.requireNonNull(ContextCompat.getDrawable(this, R.drawable.e2)), 1500);
        }
        else
        {
            mp = MediaPlayer.create(this, R.raw.wingame);
            mp.start();

            anim.addFrame(Objects.requireNonNull(ContextCompat.getDrawable(this, R.drawable.v1)), 1000);
            anim.addFrame(Objects.requireNonNull(ContextCompat.getDrawable(this, R.drawable.v2)), 1000);
            anim.addFrame(Objects.requireNonNull(ContextCompat.getDrawable(this, R.drawable.v3)), 1000);
            anim.addFrame(Objects.requireNonNull(ContextCompat.getDrawable(this, R.drawable.v4)), 1000);
            anim.addFrame(Objects.requireNonNull(ContextCompat.getDrawable(this, R.drawable.v5)), 1000);
            anim.addFrame(Objects.requireNonNull(ContextCompat.getDrawable(this, R.drawable.v6)), 1000);
            anim.addFrame(Objects.requireNonNull(ContextCompat.getDrawable(this, R.drawable.v7)), 1000);
        }
        image.setBackground(anim);
        anim.start();
    }

   public void continueToNextWord(View view) {
        // Pasa la información necesaria para la nueva palabra
        Intent resultIntent = new Intent();
        resultIntent.putExtra("continue", true);
        setResult(RESULT_OK, resultIntent);
        finish();
    }

    public void closeActivityEndGame(View view)
    {
        Intent intent = new Intent(EndGameActivity.this, Temas.class);
        intent.putExtra("openEndGameActivity", true);
        startActivity(intent);
    }

    public void showEndGameDialog(String message) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage(message)
                .setPositiveButton("OK", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        Intent intent = new Intent(EndGameActivity.this, Temas.class);
                        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
                        startActivity(intent);
                        finish();
                    }
                });

        AlertDialog dialog = builder.create();
        dialog.show();
    }
}
