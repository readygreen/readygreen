import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.ddubucks.readygreen.R

// 커스텀 폰트 패밀리 설정
val customFontFamily = FontFamily(
    Font(R.font.hakgyoansim_dunggeunmiso_bold, FontWeight.Bold),
    Font(R.font.hakgyoansim_dunggeunmiso_regular, FontWeight.Normal)
)

// 개별 텍스트 스타일 정의
val h1Style = TextStyle(
    fontFamily = customFontFamily,
    fontWeight = FontWeight.Bold,
    fontSize = 30.sp
)

val body1Style = TextStyle(
    fontFamily = customFontFamily,
    fontWeight = FontWeight.Normal,
    fontSize = 16.sp
)

val buttonStyle = TextStyle(
    fontFamily = customFontFamily,
    fontWeight = FontWeight.Medium,
    fontSize = 14.sp
)
