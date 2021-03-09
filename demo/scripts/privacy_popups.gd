extends Node

var privacy

onready var gdprPopup: PopupDialog = $"../CanvasLayer/PdGdpr"
onready var coppaPopup: PopupDialog = $"../CanvasLayer/PdCoppa"
onready var ccpaPopup: PopupDialog = $"../CanvasLayer/PdCcpa"

# Called when the node enters the scene tree for the first time.
func _ready():
	privacy = Privacy.new()
	privacy.init()
	if not privacy.is_privacy_stored():
		gdprPopup.popup()


func _on_PdGdpr_Yes_pressed():
	privacy.set_gdpr(true)
	gdprPopup.hide()
	coppaPopup.popup()


func _on_PdGdpr_No_pressed():
	privacy.set_gdpr(false)
	gdprPopup.hide()
	coppaPopup.popup()


func _on_PdCoppa_Yes_pressed():
	privacy.set_coppa(true)
	coppaPopup.hide()
	ccpaPopup.popup()


func _on_PdCoppa_No_pressed():
	privacy.set_coppa(false)
	coppaPopup.hide()
	ccpaPopup.popup()


func _on_PdCcpa_Yes_pressed():
	privacy.set_ccpa(true)
	ccpaPopup.hide()


func _on_PdCcpa_No_pressed():
	privacy.set_ccpa(false)
	ccpaPopup.hide()
