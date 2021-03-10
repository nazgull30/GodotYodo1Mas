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
	file.set_value("privacy", "gdpr", str(val))
	file.save(privacyFile)
	
func is_gdpr() -> bool:
	var gdpr = file.get_value("privacy", "gdpr", "null");
	if gdpr == "null":
		return false
	else:
		return to_bool(gdpr);
	
func set_coppa(val: bool):
	file.set_value("privacy", "coppa", str(val))
	file.save(privacyFile)

func is_coppa() -> bool:
	var coppa = file.get_value("privacy", "coppa", "null");
	if coppa == "null":
		return false
	else:
		return to_bool(coppa);	
	
func set_ccpa(val: bool):
	file.set_value("privacy", "ccpa", str(val))
	file.save(privacyFile)	

func is_ccpa() -> bool:
	var ccpa = file.get_value("privacy", "ccpa", "null");
	if ccpa == "null":
		return false
	else:
		return to_bool(ccpa);		

func is_privacy_stored() -> bool:
	var gdpr = file.get_value("privacy", "gdpr", "null");
	var coppa = file.get_value("privacy", "coppa", "null");
	var ccpa = file.get_value("privacy", "ccpa", "null");
	print("gdpr: " + gdpr + ", coppa: " + coppa + ", ccpa: " + ccpa)
	return gdpr != "null" && coppa != "null" && ccpa != "null";
	

func to_bool(strVal: String) -> bool:
	if strVal == "True":
		return true
	elif strVal == "False":
		return false
	push_error("to_bool, str: " + strVal)	
	return false
		
	
