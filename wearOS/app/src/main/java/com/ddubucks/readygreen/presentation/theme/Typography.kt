import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.ddubucks.readygreen.R

val customFontFamily = FontFamily(
    Font(R.font.hakgyoansim_dunggeunmiso_bold, FontWeight.Bold),
    Font(R.font.hakgyoansim_dunggeunmiso_regular, FontWeight.Normal)
)

val h1Style = TextStyle(
    fontFamily = customFontFamily,
    fontWeight = FontWeight.Bold,
    fontSize = 22.sp
)

val h3Style = TextStyle(
    fontFamily = customFontFamily,
    fontWeight = FontWeight.Bold,
    fontSize = 14.sp
)