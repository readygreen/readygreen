import android.content.Context
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ddubucks.readygreen.presentation.retrofit.RestClient
import com.ddubucks.readygreen.presentation.retrofit.TokenManager
import com.ddubucks.readygreen.presentation.retrofit.navigation.NavigationApi
import com.ddubucks.readygreen.presentation.retrofit.navigation.NavigationRequest
import com.ddubucks.readygreen.presentation.retrofit.navigation.NavigationResponse
import com.ddubucks.readygreen.presentation.retrofit.navigation.NavigationState
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class NavigationViewModel : ViewModel() {

    private val _navigationState = MutableStateFlow(NavigationState())
    val navigationState: StateFlow<NavigationState> = _navigationState

    // 길안내 시작 함수
    fun startNavigation(context: Context, startX: Double, startY: Double, endX: Double, endY: Double, startName: String, endName: String) {
        val accessToken = TokenManager.getToken(context)

        val navigationRequest = NavigationRequest(
            startX = startX,
            startY = startY,
            endX = endX,
            endY = endY,
            startName = startName,
            endName = endName,
            watch = true // watch는 true로 고정
        )

        val navigationApi = accessToken?.let { RestClient.createService(NavigationApi::class.java, it) }

        navigationApi?.startNavigation(navigationRequest)?.enqueue(object : Callback<NavigationResponse> {
            override fun onResponse(call: Call<NavigationResponse>, response: Response<NavigationResponse>) {
                if (response.isSuccessful) {

                    val navigationResponse = response.body()
                    Log.d("NavigationViewModel", "길안내 시작 성공: ${navigationResponse?.routeDTO}")
                    _navigationState.value = NavigationState(
                        isNavigating = true,
                        destinationName = endName,
                        destinationLat = endX,
                        destinationLng = endY
                    )
                } else {
                    Log.e("NavigationViewModel", "길안내 시작 실패: ${response.errorBody()?.string()}")
                }
            }

            override fun onFailure(call: Call<NavigationResponse>, t: Throwable) {
                Log.e("NavigationViewModel", "길안내 시작 오류", t)
            }
        })
    }

    // 길안내 중단 함수
    fun stopNavigation() {
        _navigationState.value = NavigationState()
    }
}
