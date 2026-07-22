package com.example.uso_tic.hangman;
import android.widget.ImageView;
import java.util.HashMap;
import java.util.Map;
import com.example.uso_tic.R;
public class HangmanVisualizer {

    private final ImageView hangmanView;
    private Map<Integer, Integer> imageResourceMap;

    public HangmanVisualizer(ImageView hangmanView)
    {
        this.hangmanView = hangmanView;
        initializeImageMap();
    }

    private void initializeImageMap()
    {
        imageResourceMap = new HashMap<>();
        imageResourceMap.put(-1, R.drawable.ahoracdoport);
        imageResourceMap.put(0, R.drawable.aho1);
        imageResourceMap.put(1, R.drawable.aho2);
        imageResourceMap.put(2, R.drawable.aho3);
        imageResourceMap.put(3, R.drawable.aho4);
        imageResourceMap.put(4, R.drawable.aho5);
        imageResourceMap.put(5, R.drawable.aho6);
        imageResourceMap.put(6, R.drawable.aho7);
        imageResourceMap.put(7, R.drawable.aho8);
        imageResourceMap.put(8, R.drawable.aho9);
    }

    public void updateHangmanImage(int wrongGuessCount)
    {
        Integer imageResId = imageResourceMap.get(wrongGuessCount);
        if (imageResId != null)
        {
            hangmanView.setImageResource(imageResId);
        }
    }

    public void resetHangman() {
        updateHangmanImage(-1);
    }
}
