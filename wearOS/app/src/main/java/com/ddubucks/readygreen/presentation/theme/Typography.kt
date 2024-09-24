import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.ddubucks.readygreen.R

// 폰트

val TitleFontFamily = FontFamily(
    Font(R.font.hakgyoansim_dunggeunmiso_bold, FontWeight.Bold),
    Font(R.font.hakgyoansim_dunggeunmiso_regular, FontWeight.Normal)
)

val ContentFontFamily = FontFamily(
    Font(R.font.pretendard_black, FontWeight.Black),
    Font(R.font.pretendard_bold, FontWeight.Bold),
    Font(R.font.pretendard_regular, FontWeight.Normal),
)

val NumberFontFamily = FontFamily(
    Font(R.font.round_wind_extrabold, FontWeight.ExtraBold),
    Font(R.font.round_wind_regular, FontWeight.Normal),
)


// 스타일

val h1Style = TextStyle(
    fontFamily = TitleFontFamily,
    fontWeight = FontWeight.Bold,
    fontSize = 22.sp
)

val h3Style = TextStyle(
    fontFamily = TitleFontFamily,
    fontWeight = FontWeight.Bold,
    fontSize = 14.sp
)

val pStyle = TextStyle(
    fontFamily = ContentFontFamily,
    fontSize = 14.sp,
    fontWeight = FontWeight.Normal
)

val secStyle = TextStyle(
    fontFamily = NumberFontFamily,
    fontSize = 40.sp,
    fontWeight = FontWeight.ExtraBold
)