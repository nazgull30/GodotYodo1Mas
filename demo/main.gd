extends Node2D

onready var yodo1mas = $Yodo1Mas
onready var debug_out = $CanvasLayer/Orange/DebugOut

# buttons callbacks
	
func _on_BtnBannerAd_pressed():
	debug_out.text = debug_out.text + "Banner loaded before shown = " + str(yodo1mas.is_banner_ad_loaded()) +"\n"
	yodo1mas.show_banner_ad()
	debug_out.text = debug_out.text + "Banner loaded after shown = " + str(yodo1mas.is_banner_ad_loaded()) +"\n"

func _on_BtnInterstitialAd_pressed() -> void:
	debug_out.text = debug_out.text + "Interstitial loaded before shown = " + str(yodo1mas.is_interstitial_ad_loaded()) +"\n"
	yodo1mas.show_interstitial_ad()
	debug_out.text = debug_out.text + "Interstitial loaded after shown = " + str(yodo1mas.is_interstitial_ad_loaded()) +"\n"

func _on_RewardedAd_pressed() -> void:
	debug_out.text = debug_out.text + "Rewarded video loaded before shown = " + str(yodo1mas.is_rewarded_ad_loaded()) +"\n"
	yodo1mas.show_rewarded_ad()
	debug_out.text = debug_out.text + "Rewarded video loaded after shown = " + str(yodo1mas.is_rewarded_ad_loaded()) + "\n"
	
	
	
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
