extends Node

class_name Yodo1Mas, "res://admob-lib/icon.png"

# signals
signal banner_failed_to_load(error_code)
signal interstitial_failed_to_load(error_code)
signal interstitial_closed
signal rewarded_video_closed
signal rewarded(currency, ammount)
signal rewarded_video_left_application
signal rewarded_video_failed_to_load(error_code)
signal rewarded_video_opened
signal rewarded_video_started

# properties
export var app_id:String
export var banner_on_top:bool = true
export(String, "ADAPTIVE_BANNER", "SMART_BANNER", "BANNER", "LARGE_BANNER", "MEDIUM_RECTANGLE", "FULL_BANNER", "LEADERBOARD") var banner_size = "ADAPTIVE_BANNER"
export var banner_id:String
export var interstitial_id:String
export var rewarded_id:String
export var child_directed:bool = false
export var is_personalized:bool = true
export(String, "G", "PG", "T", "MA") var max_ad_content_rate = "G"

# "private" properties
var _yodo1mas_singleton = null

func max_ad_content_rate_set(new_val) -> void:
	if new_val != "G" and new_val != "PG" \
		and new_val != "T" and new_val != "MA":
			
		max_ad_content_rate = "G"
		print("Invalid max_ad_content_rate, using 'G'")


# initialization
func init() -> bool:
	print("Initialize yodo sdk")
	if(Engine.has_singleton("GodotYodo1Mas")):
		_yodo1mas_singleton = Engine.get_singleton("GodotYodo1Mas")

		var initialized = _yodo1mas_singleton.isInitialized();
		print("_yodo1mas_singleton initialized: " + initialized)
		# check if one signal is already connected
		if not initialized:
			connect_signals()

		_yodo1mas_singleton.init(app_id)
		return true
	return false

# connect the AdMob Java signals
func connect_signals() -> void:
	_yodo1mas_singleton.connect("on_interstitial_open", self, "_on_interstitial_open")
	_yodo1mas_singleton.connect("on_interstitial_close", self, "_on_interstitial_close")
	_yodo1mas_singleton.connect("on_interstitial_error", self, "_on_interstitial_error")
#	_yodo1mas_singleton.connect("on_rewarded_video_ad_loaded", self, "_on_rewarded_video_ad_loaded")
#	_yodo1mas_singleton.connect("on_rewarded_video_ad_closed", self, "_on_rewarded_video_ad_closed")
#	_yodo1mas_singleton.connect("on_rewarded", self, "_on_rewarded")
#	_yodo1mas_singleton.connect("on_rewarded_video_ad_left_application", self, "_on_rewarded_video_ad_left_application")
#	_yodo1mas_singleton.connect("on_rewarded_video_ad_failed_to_load", self, "_on_rewarded_video_ad_failed_to_load")
#	_yodo1mas_singleton.connect("on_rewarded_video_ad_opened", self, "_on_rewarded_video_ad_opened")
#	_yodo1mas_singleton.connect("on_rewarded_video_started", self, "_on_rewarded_video_started")
	
# load

func load_banner() -> void:
	if _yodo1mas_singleton != null:
		_yodo1mas_singleton.loadBanner(banner_id, banner_on_top, banner_size)

func load_interstitial() -> void:
	if _yodo1mas_singleton != null:
		_yodo1mas_singleton.loadInterstitial(interstitial_id)
	
		
func load_rewarded_video() -> void:
	if _yodo1mas_singleton != null:
		_yodo1mas_singleton.loadRewardedVideo(rewarded_id)

# show / hide

func show_banner() -> void:
	if _yodo1mas_singleton != null:
		_yodo1mas_singleton.showBanner()
		
func hide_banner() -> void:
	if _yodo1mas_singleton != null:
		_yodo1mas_singleton.hideBanner()

func move_banner(on_top: bool) -> void:
	if _yodo1mas_singleton != null:
		banner_on_top = on_top
		_yodo1mas_singleton.move(banner_on_top)

func show_interstitial() -> void:
	if _yodo1mas_singleton != null:
		_yodo1mas_singleton.showInterstitial()
		
func show_rewarded_video() -> void:
	if _yodo1mas_singleton != null:
		_yodo1mas_singleton.showRewardedVideo()

# resize

func banner_resize() -> void:
	if _yodo1mas_singleton != null:
		_yodo1mas_singleton.resize()
		
# dimension
func get_banner_dimension() -> Vector2:
	if _yodo1mas_singleton != null:
		return Vector2(_yodo1mas_singleton.getBannerWidth(), _yodo1mas_singleton.getBannerHeight())
	return Vector2()

# callbacks

func _on_admob_ad_loaded() -> void:
	emit_signal("banner_loaded")
	
func _on_admob_banner_failed_to_load(error_code:int) -> void:
	emit_signal("banner_failed_to_load", error_code)
	
func _on_interstitial_loaded() -> void:
	emit_signal("interstitial_loaded")

func _on_interstitial_open() -> void:
	print("Godot app -> yodo1mas, _on_interstitial_open")
	emit_signal("interstitial_closed")
	
func _on_interstitial_close() -> void:
	print("Godot app -> yodo1mas, _on_interstitial_close")
	emit_signal("interstitial_closed")
	
func _on_interstitial_error(error_code:int) -> void:
	print("Godot app -> yodo1mas, error_code: " + String(error_code))
	emit_signal("interstitial_failed_to_load", error_code)


func _on_rewarded_video_ad_loaded() -> void:
	emit_signal("rewarded_video_loaded")

func _on_rewarded_video_ad_closed() -> void:
	emit_signal("rewarded_video_closed")

func _on_rewarded(currency:String, amount:int) -> void:
	emit_signal("rewarded", currency, amount)
	
func _on_rewarded_video_ad_left_application() -> void:
	emit_signal("rewarded_video_left_application")
	
func _on_rewarded_video_ad_failed_to_load(error_code:int) -> void:
	emit_signal("rewarded_video_failed_to_load", error_code)
	
func _on_rewarded_video_ad_opened() -> void:
	emit_signal("rewarded_video_opened")
	
func _on_rewarded_video_started() -> void:
	emit_signal("rewarded_video_started")
