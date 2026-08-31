class_name AudioLibrary
extends RefCounted

const SAMPLE_RATE := 8000
const AMBIENCE_SECONDS := 2.0
const MUSIC_SECONDS := 4.0


static func cemetery_ambience() -> AudioStreamWAV:
	return _make_stream(AMBIENCE_SECONDS, _cemetery_sample, true)


static func interior_ambience() -> AudioStreamWAV:
	return _make_stream(AMBIENCE_SECONDS, _interior_sample, true)


static func funeral_delivery() -> AudioStreamWAV:
	return _make_stream(0.55, _funeral_sample, false)


static func decision_cremate() -> AudioStreamWAV:
	return _make_stream(0.6, _cremate_sample, false)


static func decision_research() -> AudioStreamWAV:
	return _make_stream(0.6, _research_sample, false)


static func graveyard_theme() -> AudioStreamWAV:
	return _make_stream(MUSIC_SECONDS, _music_sample, true)


static func _make_stream(duration: float, sampler: Callable, looped: bool) -> AudioStreamWAV:
	var sample_count := int(duration * SAMPLE_RATE)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	for index in sample_count:
		var time := float(index) / SAMPLE_RATE
		var value := clampf(float(sampler.call(time)), -0.65, 0.65)
		var pcm := int(value * 32767.0)
		bytes[index * 2] = pcm & 0xFF
		bytes[index * 2 + 1] = (pcm >> 8) & 0xFF

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	if looped:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = sample_count
	return stream


static func _cemetery_sample(time: float) -> float:
	var wind := sin(TAU * 0.19 * time) * 0.035 + sin(TAU * 0.31 * time + 1.1) * 0.02
	var drone := sin(TAU * 82.0 * time) * 0.012 + sin(TAU * 123.0 * time) * 0.006
	return wind + drone


static func _interior_sample(time: float) -> float:
	var hum := sin(TAU * 55.0 * time) * 0.025 + sin(TAU * 110.0 * time) * 0.01
	var room := sin(TAU * 0.35 * time) * sin(TAU * 72.0 * time) * 0.008
	return hum + room


static func _funeral_sample(time: float) -> float:
	var envelope := exp(-7.0 * time)
	return envelope * (sin(TAU * 392.0 * time) * 0.18 + sin(TAU * 588.0 * time) * 0.11)


static func _cremate_sample(time: float) -> float:
	var envelope := exp(-6.0 * time)
	var frequency := 220.0 - 80.0 * time
	return envelope * sin(TAU * frequency * time) * 0.20


static func _research_sample(time: float) -> float:
	var envelope := exp(-5.0 * time)
	return envelope * (
		sin(TAU * 330.0 * time) * 0.12
		+ sin(TAU * 495.0 * time) * 0.10
		+ sin(TAU * 660.0 * time) * 0.06
	)


static func _music_sample(time: float) -> float:
	var phrase := int(time / 2.0) % 2
	var frequency := 110.0 if phrase == 0 else 146.83
	return sin(TAU * frequency * time) * 0.035 + sin(TAU * 55.0 * time) * 0.012
