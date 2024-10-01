import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class SearchViewModel : ViewModel() {
    private val _voiceResult = MutableStateFlow<String>("")
    val voiceResult: StateFlow<String> get() = _voiceResult

    fun updateVoiceResult(result: String) {
        viewModelScope.launch {
            _voiceResult.value = result
        }
    }
}
