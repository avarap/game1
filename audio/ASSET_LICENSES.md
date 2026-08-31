# Audio asset provenance and license

All sounds in the AUDIO #93 baseline are original deterministic procedural synthesis created specifically for `avarap/game1`. No third-party recordings, samples, melodies, stems or copyrighted game audio are used.

The synthesis source lives in `audio/synthesis/audio_library.gd` and generates the runtime PCM streams for:

- cemetery ambience;
- interior ambience;
- funeral-delivery feedback;
- cremation terminal-decision feedback;
- research terminal-decision feedback;
- the minimal graveyard music bed.

These audio assets and their synthesis definitions are dedicated to the public domain under **CC0 1.0 Universal**. The repository may use, modify and redistribute them without attribution requirements.

Mix intent: all generated source samples are clamped below full scale, with individual synthesis peaks kept well below 0 dBFS. Runtime routing applies additional attenuation on Master/Music/Ambience/SFX to retain headroom when layers overlap.
