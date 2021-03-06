# Godot 2.1 only passes platform. Godot 3+ build passes env, platform
def can_build(*argv):
	platform = argv[1] if len(argv) == 2 else argv[0]
	return platform=="android" or platform=="iphone"

def configure(env):
            
	if env['platform'] == "iphone":
		env.Append(CPPPATH=['#core'])
		env.Append(LINKFLAGS=['-ObjC','-framework'])