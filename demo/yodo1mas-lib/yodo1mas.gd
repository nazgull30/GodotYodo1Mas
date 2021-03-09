extends Node

class_name Yodo1Mas, "res://yodo1mas-lib/icon.png"

enum BannerAlign {
	BANNER_LEFT = 1, 
	BANNER_HORIZONTAL_CENTER = 1 << 1, # 2
	BANNER_RIGT = 1 << 2, # 4
	BANNER_TOP = 1 << 3, # 8
	BANNER_VERTICAL_CENTER = 1 << 4, # 16
	BANNER_BOTTOM = 1 << 5 # 32
	}

# signals
signal banner_ad_not_loaded()
signal banner_ad_opened()
signal banner_ad_closed()
signal banner_ad_error()

signal interstitial_ad_not_loaded()
signal interstitial_ad_opened()
signal interstitial_ad_closed()
signal interstitial_ad_error()

signal rewarded_ad_not_loaded()
signal rewarded_ad_opened()
signal rewarded_ad_closed()
signal rewarded_ad_error()

# properties
export var app_id_ios: String
export var app_id_android: String

# "private" properties
var _yodo1mas_singleton = null

# initialization

func set_gdpr(gdpr) -> void:
	_yodo1mas_singleton.setGdpr(gdpr)

func set_ccpa(ccpa) -> void:
	_yodo1mas_singleton.setCCPA(ccpa)
	
func set_coppa(coppa) -> void:
	_yodo1mas_singleton.setCOPPA(coppa)

func init() -> bool:
	print("Initialize yodo sdk")
	if(Engine.has_singleton("GodotYodo1Mas")):
		_yodo1mas_singleton = Engine.get_singleton("GodotYodo1Mas")

		# check if one signal is already connected
		if not _yodo1mas_singleton.is_connected("on_bannedAd_not_loaded", self, "_on_bannedAd_not_loaded"):
			connect_signals()
			connect_signals()
		
		print("OS.get_name()")

		if OS.get_name() == "iOS":
			_yodo1mas_singleton.init(app_id_ios)
		elif OS.get_name() == "Android":
			_yodo1mas_singleton.init(app_id_android)
		else:
			print("NOT ")
			
		return true
	return false

# connect the AdMob Java signals
func connect_signals() -> void:	
	
	_yodo1mas_singleton.connect("on_bannedAd_not_loaded", self, "_on_bannedAd_not_loaded")
	_yodo1mas_singleton.connect("on_bannerAd_opened", self, "_on_bannerAd_opened")
	_yodo1mas_singleton.connect("on_bannerAd_closed", self, "_on_bannerAd_closed")
	_yodo1mas_singleton.connect("on_bannerAd_error", self, "_on_bannerAd_error")
	
	_yodo1mas_singleton.connect("on_interstitial_ad_not_loaded", self, "_on_interstitial_ad_not_loaded")
	_yodo1mas_singleton.connect("on_interstitial_ad_opened", self, "_on_interstitial_ad_opened")
	_yodo1mas_singleton.connect("on_interstitial_ad_closed", self, "_on_interstitial_ad_closed")
	_yodo1mas_singleton.connect("on_interstitial_ad_error", self, "_on_interstitial_ad_error")
	
	_yodo1mas_singleton.connect("on_rewarded_ad_not_loaded", self, "_on_rewarded_ad_not_loaded")
	_yodo1mas_singleton.connect("on_rewarded_ad_opened", self, "_on_rewarded_ad_opened")
	_yodo1mas_singleton.connect("on_rewarded_ad_closed", self, "_on_rewarded_ad_closed")
	_yodo1mas_singleton.connect("on_rewarde_ad_earned", self, "_on_rewarded_ad_earned")
	_yodo1mas_singleton.connect("on_rewarded_ad_error", self, "_on_rewarded_ad_error")
	


# show / hide

func is_banner_ad_loaded() -> bool:
	if(_yodo1mas_singleton == null):
		return false;	
	return _yodo1mas_singleton.isBannerAdLoaded();
		
func show_banner_ad() -> void:
	if(_yodo1mas_singleton != null):
		_yodo1mas_singleton.showBanner()
		
func show_banner_ad_with_align(align: int) -> void:
	if(_yodo1mas_singleton != null):
		_yodo1mas_singleton.showBannerAdWithAlign(align)

func show_banner_ad_with_align_and_offset(align: int, offset: Vector2) -> void:
	if(_yodo1mas_singleton != null):
		_yodo1mas_singleton.showBannerAdWithAlign(align, offset.x, offset.y)		
		
		
func dismiss_banner_ad() -> void:
	if(_yodo1mas_singleton != null):
		_yodo1mas_singleton.dismissBannerAd()

func is_interstitial_ad_loaded() -> bool:
	if(_yodo1mas_singleton == null):
		return false;
	return _yodo1mas_singleton.isInterstitialAdLoaded()
	
func show_interstitial_ad() -> void:
	if(_yodo1mas_singleton != null):
		_yodo1mas_singleton.showInterstitialAd()

func is_rewarded_ad_loaded() -> bool:
	if(_yodo1mas_singleton == null):
		return false;
	return _yodo1mas_singleton.isRewardedAdLoaded()
	
func show_rewarded_ad() -> void:
	if(_yodo1mas_singleton != null):
		_yodo1mas_singleton.showRewardedAd()

# callbacks

func _on_banner_ad_not_loaded() -> void:
	emit_signal("banner_ad_not_loaded")

func _on_banner_ad_opened() -> void:
	emit_signal("banner_ad_not_opened")
	
func _on_banner_ad_closed() -> void:
	emit_signal("banner_ad_not_closed")

func _on_banner_ad_error() -> void:
	emit_signal("banner_ad_not_error")


func _on_interstitial_ad_not_loaded() -> void:
	emit_signal("interstitial_ad_not_loaded")

func _on_interstitial_ad_opened() -> void:
	emit_signal("interstitial_ad_opened")	
	
func _on_interstitial_ad_closed() -> void:
	emit_signal("interstitial_ad_closed")
	
func _on_interstitial_ad_error(error_code:int) -> void:
	emit_signal("interstitial_ad_error", error_code)
	
			
func _on_interstitial_opened() -> void:
	print("Godot app -> yodo1mas, _on_interstitial_opened")
	emit_signal("interstitial_closed")
	
func _on_interstitial_closed() -> void:
	print("Godot app -> yodo1mas, _on_interstitial_closed")
	emit_signal("interstitial_closed")


func _on_rewarded_ad_not_loaded() -> void:
	emit_signal("rewarded_ad_not_loaded")
	
func _on_rewarded_ad_opened() -> void:
	emit_signal("rewarded_ad_opened")

func _on_rewarded_ad_closed() -> void:
	emit_signal("rewarded_ad_closed")
	
func _on_rewarded_ad_earned() -> void:
	emit_signal("rewarded_ad_earned")
		
func _on_rewarded_ad_error(error_code:int) -> void:
	emit_signal("rewarded_ad_error", error_code)
	
