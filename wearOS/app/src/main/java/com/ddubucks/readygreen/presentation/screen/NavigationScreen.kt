import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.wear.compose.material.Icon
import androidx.wear.compose.material.Text
import com.ddubucks.readygreen.R
import com.ddubucks.readygreen.presentation.theme.Red
import com.ddubucks.readygreen.presentation.theme.Yellow
import h3Style
import pStyle
import secStyle

@Composable
fun NavigationScreen(
    navigationViewModel: NavigationViewModel = viewModel() // ViewModel 주입
) {
    val navigationState = navigationViewModel.navigationState.collectAsState().value // 경로 상태 구독

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        if (navigationState.isNavigating) {
            // 경로 안내 화면
            Text(
                text = "경로 안내: ${navigationState.destinationName}",
                style = h3Style,
                color = Yellow,
            )

            Spacer(modifier = Modifier.height(10.dp))

            Icon(
                painter = painterResource(id = R.drawable.arrow_left),
                contentDescription = "방향",
                tint = Color.Unspecified,
                modifier = Modifier
                    .size(80.dp)
                    .padding(top = 20.dp)
            )

            Spacer(modifier = Modifier.height(10.dp))

            Text(
                text = "목적지 좌표: 위도 ${navigationState.destinationLat}, 경도 ${navigationState.destinationLng}",
                fontWeight = FontWeight.Bold,
                style = pStyle,
                color = Color.White,
            )

            Spacer(modifier = Modifier.height(10.dp))

            Text(
                text = "남은 거리: 50m",
                fontWeight = FontWeight.Bold,
                style = secStyle,
                color = Red,
            )
        } else {
            // 길안내 중이 아닐 때
            Text(
                text = "길안내 중이 아닙니다.",
                style = h3Style,
                color = Color.White
            )
        }
    }
}
