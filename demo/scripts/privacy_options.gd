extends PopupDialog

onready var cbGdpr: CheckButton = $cbPrivacy_Gdpr
onready var cbCoppa: CheckButton = $cbPrivacy_Coppa
onready var cbCcpa: CheckButton = $cbPrivacy_Ccpa

var privacy: Privacy

func init():
	privacy = Privacy.new()

func _on_PdPrivacy_about_to_show():
	privacy.init()
	cbGdpr.pressed = privacy.is_gdpr()
	cbCoppa.pressed = privacy.is_coppa()
	cbCcpa.pressed = privacy.is_ccpa()
	
func _on_BtnPrivacy_Close_pressed():
	hide()


func _on_cbPrivacy_Gdpr_toggled(button_pressed):
	print("gdpr -> button_pressed: " + str(button_pressed))
	privacy.set_gdpr(button_pressed)


func _on_cbPrivacy_Coppa_toggled(button_pressed):
	privacy.set_coppa(button_pressed)


func _on_cbPrivacy_Ccpa_toggled(button_pressed):
	privacy.set_ccpa(button_pressed)

