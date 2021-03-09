#include <version_generated.gen.h>

#if VERSION_MAJOR == 3
#include <core/class_db.h>
#include <core/engine.h>
#else
#include "object_type_db.h"
#include "core/globals.h"
#endif

#include "register_types.h"
#include "ios/src/GodotYodo1Mas.h"

void register_yodo1mas_types() {
#if VERSION_MAJOR == 3
    Engine::get_singleton()->add_singleton(Engine::Singleton("GodotYodo1Mas", memnew(GodotYodo1Mas)));
#else
    Globals::get_singleton()->add_singleton(Globals::Singleton("GodotYodo1Mas", memnew(GodotYodo1Mas)));
#endif
}

void unregister_yodo1mas_types() {
}
