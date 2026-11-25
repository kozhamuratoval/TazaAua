import Testing
@testable import TazaAua

struct AQICategoryTests {
    @Test(arguments: [
        (0, AQICategory.good),
        (50, AQICategory.good),
        (51, AQICategory.moderate),
        (100, AQICategory.moderate),
        (101, AQICategory.unhealthyForSensitiveGroups),
        (150, AQICategory.unhealthyForSensitiveGroups),
        (151, AQICategory.unhealthy),
        (200, AQICategory.unhealthy),
        (201, AQICategory.veryUnhealthy),
        (300, AQICategory.veryUnhealthy),
        (301, AQICategory.hazardous),
        (500, AQICategory.hazardous),
    ])
    func categoryMatchesEPABoundaries(aqi: Int, expected: AQICategory) {
        #expect(AQICategory(aqi: aqi) == expected)
    }
}
