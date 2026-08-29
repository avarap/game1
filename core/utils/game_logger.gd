class_name GameLogger
extends RefCounted

static func info(message: String) -> void:
    print("[INFO] %s" % message)

static func warn(message: String) -> void:
    push_warning("[WARN] %s" % message)

static func error(message: String) -> void:
    push_error("[ERROR] %s" % message)
