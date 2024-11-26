extends Node2D
class_name BasePickup

@export_category("Icon")
@export var texture:Texture2D
@export var tex_scale:float = 0.125
@export var type:Pickup = Pickup.UNASSIGNED
@export var mods:Dictionary


@onready var sprite:Sprite2D = $Sprite2D

enum Pickup { 
	UNASSIGNED,
	base_chip,
	snipe_chip,
	spread_chip,
	repeat_chip,
	slug_chip,
	blade_chip,
	transformer,
	radiator,
	power_converter,
	power_diverter,
	voltage_regulator,
	dual_processors,
	wide_lens,
	short_circuit,
	power_adapter,
	malware,
	magnet,
	overclock,
	virus,
	ram
}

var pickups:Dictionary = {
	Pickup.base_chip: {
		"texture": "res://Scenes/Pickups/Pickup_PNGS/basechip.png",
		"mods": {
			"bullet_damage": "=5",
			"bullet_speed": "=1",
			"bullet_range": "=10",
			"bullet_size": "=1",
			"bullet_firing_rate": "=1",
			"bullet_accuracy": "=1",
			"bullet_piercing": "=1",
			"bullet_count": "=1",
			"melee_damage": "=5",
			"dodge_speed": "=1",
			"stamina": "=4"
		}
	},
	Pickup.snipe_chip: {
		"texture": "",
		"mods": {
			"bullet_damage": "=8",
			"bullet_speed": "=2",
			"bullet_range": "=16",
			"bullet_size": "=0.5",
			"bullet_firing_rate": "=0.5",
			"bullet_accuracy": "=1.5",
			"bullet_piercing": "=2",
			"bullet_count": "=1",
			"melee_damage": "=5",
			"dodge_speed": "=1",
			"stamina": "=4"
		}
	},
	Pickup.spread_chip: {
		"texture": "",
		"mods": {
			"bullet_damage": "=3",
			"bullet_speed": "=1",
			"bullet_range": "=5",
			"bullet_size": "=1",
			"bullet_firing_rate": "=0.75",
			"bullet_accuracy": "=0.5",
			"bullet_piercing": "=1",
			"bullet_count": "=5",
			"bullet_arc": "=30",
			"melee_damage": "=5",
			"dodge_speed": "=1",
			"stamina": "=3"
		}
	},
	
	Pickup.repeat_chip: {
		"texture": "",
		"mods": {
			"bullet_damage": "=3",
			"bullet_speed": "=1",
			"bullet_range": "=8",
			"bullet_size": "=0.5",
			"bullet_firing_rate": "=2.5",
			"bullet_accuracy": "=0.9",
			"bullet_piercing": "=1",
			"bullet_count": "=1",
			"melee_damage": "=5",
			"dodge_speed": "=1",
			"stamina": "=5"
		}
	},
	Pickup.slug_chip: {
		"texture": "",
		"mods": {
			"bullet_damage": "=8",
			"bullet_speed": "=0.5",
			"bullet_range": "=4",
			"bullet_size": "=2",
			"bullet_firing_rate": "=0.5",
			"bullet_accuracy": "=1",
			"bullet_piercing": "=3",
			"bullet_count": "=1",
			"melee_damage": "=5",
			"dodge_speed": "=1",
			"stamina": "=3"
		}
	},
	Pickup.blade_chip: {
		"texture": "",
		"mods": {
			"bullet_damage": "=2",
			"bullet_speed": "=1",
			"bullet_range": "=5",
			"bullet_size": "=1",
			"bullet_firing_rate": "=0.9",
			"bullet_accuracy": "=1",
			"bullet_piercing": "=1",
			"bullet_count": "=1",
			"melee_damage": "=7",
			"dodge_speed": "=1.1",
			"stamina": "=5"
		}
	}
}

func _on_pickup_detector_body_entered(body: Node2D) -> void:
	if body is Player:
		body.add_mods(mods)
		queue_free()

func _ready() -> void:
	if type == Pickup.UNASSIGNED:
		push_warning("unassigned pickup: ", self)
	else:
		var entry:Dictionary = pickups[type]
		texture = load(entry["texture"])
		mods = entry["mods"]
	if texture != null:
		sprite.texture = texture
		sprite.scale = Vector2(tex_scale, tex_scale)
	else:
		sprite.modulate = Color.RED
