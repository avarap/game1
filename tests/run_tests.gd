extends SceneTree

func _initialize() -> void:
    var failures: Array[String] = []
    failures.append_array(TestTimeMath.run())
    failures.append_array(TestPlayerMovement.run())
    failures.append_array(TestWalkingPrototype.run())

    if failures.is_empty():
        print("[TEST] All core tests passed")
        quit(0)
        return

    for failure in failures:
        push_error("[TEST] %s" % failure)
    quit(1)
