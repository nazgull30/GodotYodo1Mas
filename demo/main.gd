extends Node2D

onready var yodo1mas = $Yodo1Mas
onready var debug_out = $CanvasLayer/DebugOut

func _ready():
# warning-ignore:return_value_discarded
	get_tree().connect("screen_resized", self, "_on_resize")

# buttons callbacks
func _on_BtnInit_pressed() -> void:
	yodo1mas.init()
	
func _on_BtnBanner_toggled(button_pressed):
		if button_pressed: yodo1mas.show_banner()
		else: yodo1mas.hide_banner()

func _on_BtnBannerMove_toggled(button_pressed: bool) -> void:
	yodo1mas.move_banner(button_pressed)
	$"CanvasLayer/BtnBannerResize".disabled = true
	$"CanvasLayer/BtnBanner".disabled = true
	$"CanvasLayer/BtnBannerMove".disabled = true

func _on_BtnBannerResize_pressed() -> void:
	yodo1mas.banner_resize()

func _on_BtnInterstitial_pressed():
	debug_out.text = debug_out.text + "Interstitial loaded before shown = " + str(yodo1mas.is_interstitial_loaded()) +"\n"
	yodo1mas.show_interstitial()
	debug_out.text = debug_out.text + "Interstitial loaded after shown = " + str(yodo1mas.is_interstitial_loaded()) +"\n"

func _on_BtnRewardedVideo_pressed():
	debug_out.text = debug_out.text + "Rewarded loaded before shown = " + str(yodo1mas.is_rewarded_video_loaded()) +"\n"
	yodo1mas.show_rewarded_video()
	debug_out.text = debug_out.text + "Rewarded loaded after shown = " + str(yodo1mas.is_rewarded_video_loaded()) +"\n"
	
	
	
# callbacks	from signals

func _on_Yodo1Mas_banner_ad_not_loaded():
	debug_out.text = debug_out.text + "Banner not loaded\n"

func _on_Yodo1Mas_banner_ad_opened():
	debug_out.text = debug_out.text + "Banner opened\n"


func _on_Yodo1Mas_banner_ad_closed():
	debug_out.text = debug_out.text + "Banner closed\n"

func _on_Yodo1Mas_banner_ad_error(error_code: int):
	debug_out.text = debug_out.text + "Banner failed to open: Error code " + str(error_code) + "\n"


func _on_Yodo1Mas_interstitial_ad_not_loaded():
	debug_out.text = debug_out.text + "Interstitial not loaded\n"

func _on_Yodo1Mas_interstitial_ad_opened():
	debug_out.text = debug_out.text + "Interstitial opened\n"

func _on_Yodo1Mas_interstitial_ad_closed():
	debug_out.text = debug_out.text + "Interstitial closed\n"

func _on_Yodo1Mas_interstitial_ad_error(error_code: int):
	debug_out.text = debug_out.text + "Interstitial failed to open: Error code " + str(error_code) + "\n"


func _on_Yodo1Mas_rewarded_ad_not_loaded():
	debug_out.text = debug_out.text + "Rewarded video not loaded\n"

func _on_Yodo1Mas_rewarded_ad_opened():
	debug_out.text = debug_out.text + "Rewarded video opened\n"

func _on_Yodo1Mas_rewarded_ad_closed():
	debug_out.text = debug_out.text + "Rewarded video closed\n"

func _on_Yodo1Mas_rewarded_ad_error(error_code: int):
	debug_out.text = debug_out.text + "Rewarded video failed to open: Error code " + str(error_code) + "\n"
