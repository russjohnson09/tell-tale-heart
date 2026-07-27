https://github.com/blacknoize404/Godot-Direct-Audio-Input-Recorder-and-WAV-24-bits-Tools.git



## Installation

```
cd libs
git clone https://github.com/blacknoize404/Godot-Direct-Audio-Input-Recorder-and-WAV-24-bits-Tools.git
cp Godot-Direct-Audio-Input-Recorder-and-WAV-24-bits-Tools/addons/direct_audio_and_wav_24bits/ -R ../addons/
```

1.  Clone or copy the contents of this repository into your project's `res://addons/direct_audio_and_wav_24bits/` directory.
2.  Go to **Project > Project Settings > Plugins**.
3.  Locate **High-Fidelity Audio Recording and WAV 24-Bit Tools** and check the **Enabled** box.
4.  Ensure your project has **Audio Input** enabled in the Project Settings (under Audio).


```
extends Node

@onready var recorder = $DirectAudioInputRecorder
@onready var player = $AudioStreamPlayerWav24B

func _on_record_button_pressed() -> void:
    recorder.start_capturing()

func _on_stop_button_pressed() -> void:
    recorder.stop_capturing()
    var recording : AudioStreamWAV24B = recorder.get_recording_as_wav24b()
    
    # Save it to the user folder
    recording.save_to_wav("user://high_fidelity_capture.wav")
    
    # Play it back immediately
    player.play_24bit(recording)
```