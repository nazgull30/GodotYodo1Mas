class_name Privacy

var file = ConfigFile.new()

var privacyFile = ""

# Called when the node enters the scene tree for the first time.
func init():
	if OS.get_name() == "iOS" || OS.get_name() == "Android":
		privacyFile = "user://privacy.cfg"
	else:
		privacyFile = "res://privacy.cfg"
		
	var status = file.load(privacyFile);
	if status != OK:
		print("Create config file")
		file.save(privacyFile)
		return;	
		
func set_gdpr(val: bool):
	file.set_value("privacy", "gdpr", val)
	file.save(privacyFile)
	
func set_coppa(val: bool):
	file.set_value("privacy", "coppa", val)
	file.save(privacyFile)
	
func set_ccpa(val: bool):
	file.set_value("privacy", "ccpa", val)
	file.save(privacyFile)	

func is_privacy_stored() -> bool:
	var gdpr = file.get_value("privacy", "gdpr");
	var coppa = file.get_value("privacy", "coppa");
	var ccpa = file.get_value("privacy", "ccpa");
	print("gdpr: " + str(gdpr) + ", coppa: " + str(coppa) + ", ccpa: " + str(ccpa))
	return gdpr != null && coppa != null && ccpa != null;
