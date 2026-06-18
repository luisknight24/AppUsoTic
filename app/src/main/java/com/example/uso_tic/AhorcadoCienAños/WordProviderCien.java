package com.example.uso_tic.AhorcadoCienAños;
import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.annotation.NonNull;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.appcompat.app.AppCompatActivity;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;
public class WordProviderCien extends AppCompatActivity {

    private static final String[] words = {"macondo", "buendia", "ursula","melquiades", "gitanos", "pergaminos","piratas", "inventos", "soledad", "aureliano"};
    private Set<String> usedWords = new HashSet<>();
    private int lastIndex = -1;

    public String getNextAvailableWord() {
        if (usedWords.size() == words.length) {
            // Todas las palabras han sido utilizadas, reiniciar el conjunto de palabras usadas.
            //return null;
            usedWords.clear();
        }

        List<String> remainingWords = new ArrayList<>(Arrays.asList(words));
        remainingWords.removeAll(usedWords);

        if (remainingWords.isEmpty()) {
            // Todas las palabras han sido utilizadas después de reiniciar.
            return null;
        }

        Collections.shuffle(remainingWords);

        String nextWord = remainingWords.get(0);
        usedWords.add(nextWord);
        return nextWord;
    }

    public LiveData<String[]> getRandomWordsAsync() {
        MutableLiveData<String[]> liveData = new MutableLiveData<>();

        // Mezclar aleatoriamente las palabras
        List<String> shuffledWords = Arrays.asList(words);
        Collections.shuffle(shuffledWords);
        String[] shuffledArray = shuffledWords.toArray(new String[0]);

        // Publicar el arreglo mezclado en el LiveData
        liveData.postValue(shuffledArray);

        return liveData;
    }
}
