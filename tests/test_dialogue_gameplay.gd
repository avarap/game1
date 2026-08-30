class_name TestDialogueGameplay
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var previous_locale := TranslationServer.get_locale()
	var tree := Engine.get_main_loop() as SceneTree
	var world_scene := load("res://world/world.tscn") as PackedScene
	if tree == null or world_scene == null:
		failures.append("Dialogue gameplay test requires SceneTree and world scene")
		return failures

	var world := world_scene.instantiate()
	tree.root.add_child(world)
	var player := world.get_node_or_null("Player")
	var aldren := world.get_node_or_null("BrotherAldren")
	var controller := world.get_node_or_null("DialogueLayer") as DialogueController
	var interactable: DialogueInteractable
	if aldren != null:
		interactable = aldren.get_node_or_null("DialogueInteractable") as DialogueInteractable

	if player == null or controller == null or interactable == null:
		failures.append("World should expose player, dialogue UI and Aldren interaction")
		world.free()
		TranslationServer.set_locale(previous_locale)
		return failures
	if interactable.dialogue == null or not interactable.dialogue.is_valid():
		failures.append("Aldren interaction should reference valid DialogueData")

	controller.set_locale("es")
	interactable.interact(player)
	if not controller.is_dialogue_active():
		failures.append("Interacting with Aldren should open the dialogue UI")
	if controller.get_current_speaker_text() != "Hermano Aldren":
		failures.append("Dialogue UI should render the Spanish speaker name")
	if not controller.get_current_body_text().begins_with("Ah, el nuevo cuidador"):
		failures.append("Dialogue UI should render the Spanish dialogue text")

	if not controller.select_option(&"identity"):
		failures.append("Playable dialogue should accept a data-driven option")
	controller.set_locale("en")
	if controller.get_current_speaker_text() != "Brother Aldren":
		failures.append("Runtime language switch should refresh the speaker name")
	if not controller.get_current_body_text().begins_with("Brother Aldren."):
		failures.append("Runtime language switch should refresh the active node text")

	controller.close_dialogue()
	if controller.is_dialogue_active():
		failures.append("Dialogue should close without mutating its data resource")

	world.free()
	TranslationServer.set_locale(previous_locale)
	return failures
