extends SceneTree

func _initialize() -> void:
    var failures: Array[String] = []
    failures.append_array(TestTimeMath.run())

    if failures.is_empty():
        print("[TEST] All bootstrap tests passed")
        quit(0)
        return

    for failure in failures:
        push_error("[TEST] %s" % failure)
    quit(1)
