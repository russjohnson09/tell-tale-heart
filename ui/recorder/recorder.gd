extends Node2D

@export var max_record_time = 60
@export var save_name: String = "test.wav"
@onready var timer_record_limit: Timer = 	$TimerLimitRecord
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var record_countdown: Label = $RecordCountdown

@onready var record_audiostream: AudioStreamPlayer = $AudioStreamPlayer
@onready var playback_audiostream: AudioStreamPlayer = $AudioStreamPlayer2

@onready var recorder = $DirectAudioInputRecorder
#@onready var player = $AudioStreamPlayerWav24B

var recording: AudioStreamWAV24B
var playback_recording: AudioStreamWAV
var record_index
var record_effect


func _ready() -> void:
	record_index = AudioServer.get_bus_index("RecordingBus")
	record_effect = AudioServer.get_bus_effect(record_index, 0)

func update_recording_volume_bar():
	var current_db = AudioServer.get_bus_peak_volume_left_db(record_index, 0)	
	var magnitude = db_to_linear(current_db)
	progress_bar.value = magnitude  * progress_bar.max_value
	pass

func _process(delta: float) -> void:

	update_recording_volume_bar()
	if timer_record_limit.is_stopped():
		record_countdown.text = ""
	else:
		record_countdown.text = str(int(timer_record_limit.time_left))
	
	#if record_effect.is_recording_active():
	if recorder.is_recording():
		#$RecordLabel.text = "Recording"
		$RecordButton.text = "Press To Stop Recording"
	else:
		$RecordButton.text = "Press To Record"
		
	if playback_audiostream.playing:
		$PlayButton.text = "Stop"

	else:
		$PlayButton.text = "Play"
		
func start_record():
	#record_effect.set_recording_active(true)
	recorder.start_capturing()
	
#https://github.com/godotengine/godot-demo-projects/blob/master/audio/mic_record/MicRecord.gd
func start_stop_recording():
	
	# stop if android does not have permission to record audio
	if not OS.request_permission("RECORD_AUDIO"):
		return
	
	if recorder.is_recording():
		stop_recording()
		return
	start_record()
	timer_record_limit.start(max_record_time)



func stop_recording():
	if not recorder.is_recording():
		return
	recorder.stop_capturing()
	timer_record_limit.stop()
	recording = recorder.get_recording_as_wav24b()
	#recording.save_to_wav("user://high_fidelity_capture.wav")
	
	print(recording)
	print(OS.get_user_data_dir() + "/" + save_name)
	recording.save_to_wav('user://%s' % save_name)
	recording = null

	#recording = record_effect.get_recording()
	#
	#var recording : AudioStreamWAV24B = recorder.get_recording_as_wav24b()
#
	## don't mess with these after the fact or lookup how to adjust these properly.
	##recording.set_mix_rate(mix_rate)
	##recording.set_format(format)
	##recording.set_stereo(stereo)
	#
	#record_effect.set_recording_active(false)
	#

func _on_timer_limit_record_timeout() -> void:
	stop_recording()
	pass # Replace with function body.


# To load an ogg at runtime you'll need to use AudioStreamOggVorbis.load_from_file()
func load_recording():
	# I always save after recording so this should always be here.
	var sound = AudioStreamWAV.load_from_file('user://%s' % save_name)
	playback_recording = sound
	return playback_recording

func _on_play_button_pressed() -> void:
	stop_recording()
	load_recording()
	
	if playback_audiostream.playing:
		playback_audiostream.stop()
		return
	if not playback_recording:
		return
	
	print_rich("\n[b]Playing recording:[/b] %s" % playback_recording)
	#print_rich("[b]Format:[/b] %s" % ("8-bit uncompressed" if playback_recording.format == 0 else "16-bit uncompressed" if recording.format == 1 else "IMA ADPCM compressed"))
	#print_rich("[b]Mix rate:[/b] %s Hz" % playback_recording.mix_rate)
	#print_rich("[b]Stereo:[/b] %s" % ("Yes" if playback_recording.stereo else "No"))
	var data := playback_recording.get_data()
	#print_rich("[b]Size:[/b] %s bytes" % data.size())
	
	playback_audiostream.stream = playback_recording
	playback_audiostream.play()


func _on_record_button_pressed() -> void:
	start_stop_recording()
