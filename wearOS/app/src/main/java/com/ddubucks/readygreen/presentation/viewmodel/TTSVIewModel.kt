package com.ddubucks.readygreen.presentation.viewmodel

import android.content.Context
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import java.util.*

class TTSViewModel(private val context: Context) : ViewModel() {

    private val _ttsReady = MutableStateFlow(false)
    val ttsReady: StateFlow<Boolean> = _ttsReady

    private var tts: TextToSpeech? = null

    init {
        tts = TextToSpeech(context) { status ->
            if (status == TextToSpeech.SUCCESS) {
                tts?.language = Locale.KOREAN
                _ttsReady.value = true
            }
        }
    }

    fun speakText(text: String, onDone: () -> Unit = {}) {
        if (_ttsReady.value) {
            tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "ttsId")
            tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                override fun onStart(utteranceId: String?) {}
                override fun onDone(utteranceId: String?) {
                    onDone()
                }
                override fun onError(utteranceId: String?) {}
            })
        }
    }

    override fun onCleared() {
        tts?.shutdown()
        super.onCleared()
    }
}
