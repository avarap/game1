class_name TestTimeMath
extends RefCounted

static func run() -> Array[String]:
    var failures: Array[String] = []

    var noon := TimeMath.normalize_total_minutes(12 * 60 + 30)
    if noon.hour != 12 or noon.minute != 30:
        failures.append("12:30 must remain 12:30")

    var wrapped := TimeMath.normalize_total_minutes(25 * 60 + 15)
    if wrapped.hour != 1 or wrapped.minute != 15:
        failures.append("25:15 must normalize to 01:15")

    if TimeMath.to_total_minutes(6, 30) != 390:
        failures.append("06:30 must equal 390 total minutes")

    return failures
