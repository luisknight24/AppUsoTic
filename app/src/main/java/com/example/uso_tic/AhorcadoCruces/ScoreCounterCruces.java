package com.example.uso_tic.AhorcadoCruces;

import android.content.Context;
import android.media.MediaPlayer;

import com.example.uso_tic.R;

public class ScoreCounterCruces {

    private int score = 0;
    private final Context context;
    private MediaPlayer mp;

    public ScoreCounterCruces(Context context) {
        this.context = context;
    }

    public int getScore() {
        return score;
    }

    public void incrementScore() {
        // Incrementa el puntaje por cada palabra adivinada
        score++;

        mp = MediaPlayer.create(context, R.raw.success);
        mp.start();
    }
}
