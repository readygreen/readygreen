package com.ddubucks.readygreen.presentation.retrofit.navigation

import kotlin.Double
import kotlin.String
import kotlin.Int
import kotlin.collections.List

// 최상위 응답 데이터 클래스
data class NavigationResponse(
    val routeDTO: RouteDTO, // 경로 정보
    val blinkerDTOs: List<BlinkerDTO>, // 신호등 정보
    val distance: Double, // 남은 거리
    val time: String // 응답 시간
)

// 경로 정보 클래스
data class RouteDTO(
    val type: String, // FeatureCollection
    val features: List<Feature> // 경로에 있는 포인트 또는 선 리스트
)

// 경로의 개별 요소 (포인트 또는 선)
data class Feature(
    val type: String, // Feature
    val geometry: Geometry, // 좌표 정보
    val properties: Properties // 속성 정보
)

// 좌표 정보 클래스 (Point 또는 LineString)
data class Geometry(
    val type: String, // Point 또는 LineString
    val coordinates: Any // 좌표 데이터 (포인트 또는 선)
) {
    // Point인 경우 Double 리스트로 변환
    fun getCoordinatesAsDoubleArray(): List<Double>? {
        return if (type == "Point") {
            (coordinates as? List<*>)
                ?.filterIsInstance<Double>() // 모든 요소가 Double인지 확인
        } else null
    }

    // LineString인 경우 리스트 내 리스트로 변환
    fun getCoordinatesAsLineString(): List<List<Double>>? {
        return if (type == "LineString") {
            (coordinates as? List<*>)
                ?.filterIsInstance<List<*>>()
                ?.map { it.filterIsInstance<Double>() } // 내부 리스트의 모든 요소가 Double인지 확인
        } else null
    }
}

// 경로의 세부 정보 (설명, 방향 등)
data class Properties(
    val description: String, // 경로 설명 (예: "계룡로을 따라 65m 이동")
    val turnType: Int, // 방향 타입 (예: 200 - 직진, 13 - 우회전)
    val name: String? // 경로 이름 (예: 도로명, 교차로명 등), 없을 수 있음
)

// 신호등 정보 클래스
data class BlinkerDTO(
    val id: Int, // 신호등 ID
    val lastAccessTime: String, // 마지막 갱신 시간
    val greenDuration: Int, // 초록불 지속 시간
    val redDuration: Int, // 빨간불 지속 시간
    val currentState: String, // 현재 신호 상태 ("GREEN" 또는 "RED")
    val remainingTime: Int, // 남은 시간 (초)
    val latitude: Double, // 신호등의 위도
    val longitude: Double // 신호등의 경도
)
