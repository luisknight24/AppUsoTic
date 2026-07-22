package com.example.uso_tic.AhorcadoCienAños;
import android.os.Build;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.Observer;

import com.example.uso_tic.hangman.WordProvider;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
public class WordManagerCien {

    private List<String> availableWords;
    private int totalAvailableWords;
    private final WordProvider provider = new WordProvider();
    private Set<Character> noDuplicateGuessedChars = new HashSet<>();

    private String searchWord = "";
    private String wrongEstimatedChars = "";
    private String guessedChars = "";
    private int currentWordIndex = 0;

    private int incorrectAttempts = 0;
    int[] allowedChars = new int[] {
            97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110,
            111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122,
            283, 353, 357, 269, 345, 382, 253, 225, 237, 233, 367, 250, 243};


    public String getGuessedChars() { return guessedChars; }
    public Set<Character> getNoDuplicateGuessedChars() { return noDuplicateGuessedChars; }
    // public String getWrongEstimatedChars() { return wrongEstimatedChars; }
    public String getSearchWord() { return searchWord;}


    public int getIncorrectAttempts() {
        return incorrectAttempts;
    }

    public void addWrongEstimatedCharsChar(char letter) {
        if (!searchWord.contains(String.valueOf(letter))) {
            incorrectAttempts++;
            if (incorrectAttempts >= 10) {
                // Si el número de intentos incorrectos es igual o mayor a 9, reiniciar el contador a cero.
                incorrectAttempts = 0;
            }
        }
    }
    public String getWrongEstimatedChars() {
        return String.valueOf(incorrectAttempts); // Regresa el número de intentos incorrectos.
    }
    public void resetIncorrectAttempts() {
        incorrectAttempts = 0;
    }
    public void reset() {
        searchWord = "";
        wrongEstimatedChars = "";
        guessedChars = "";
        currentWordIndex = 0;
        incorrectAttempts = 0;
        noDuplicateGuessedChars.clear();
    }
    public void setSearchWord(String searchWord)
    {
        this.searchWord = searchWord;
        this.wrongEstimatedChars = "";
        this.guessedChars = "";

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            noDuplicateGuessedChars = searchWord.chars()
                    .mapToObj(c -> (char) c)
                    .collect(Collectors.toSet());
        }
    }

    public void addGuessedChar(char letter)
    {
        guessedChars += letter;
    }


    public LiveData<String> generateNewWord() {
        MutableLiveData<String> liveData = new MutableLiveData<>();

        provider.getRandomWordsAsync().observeForever(new Observer<String[]>() {
            @Override
            public void onChanged(String[] words) {
                if (currentWordIndex < words.length) {
                    liveData.postValue(words[currentWordIndex]);
                    currentWordIndex++;
                } else {
                    liveData.postValue(null);  // Marcar que no hay más palabras
                }
            }
        });

        return liveData;
    }

    public int getTotalAvailableWords() {
        return totalAvailableWords;
    }


// En MainGameActivity

    public boolean isGuessedCharAllowed(char letter)
    {
        char lowerCaseLetter = Character.toLowerCase(letter);
        return Arrays.stream(allowedChars).anyMatch(x -> x == lowerCaseLetter);
    }


}
