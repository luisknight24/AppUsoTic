package com.example.uso_tic.AhorcadoCienAños;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;

import com.example.uso_tic.R;

public class WelcomeCienActivity  extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_welcome);

        if (getSupportActionBar() != null)
        {
            getSupportActionBar().hide();
        }

        ImageView iw = findViewById(R.id.imageView10);
        Animation welcomeAnimation = AnimationUtils.loadAnimation(this, R.anim.welcome_sc);
        iw.startAnimation(welcomeAnimation);

        welcomeAnimation.setAnimationListener(new Animation.AnimationListener()
        {
            @Override
            public void onAnimationEnd(Animation animation)
            {
                //Comienza una nueva actividad.
                startActivity(new Intent(WelcomeCienActivity.this, MainGameActivityCien.class));
                finish();
            }

            @Override
            public void onAnimationStart(Animation animation) {}

            @Override
            public void onAnimationRepeat(Animation animation) {}
        });
    }
}