extends Node2D
class_name BasePickup

@export var mods:Dictionary

func _on_pickup_detector_body_entered(body: Node2D) -> void:
	if body is Player:
		body.apply_mods(mods)
		queue_free()
