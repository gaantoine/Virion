extends Node2D
class_name BasePickup

var texture:Texture2D
var tex_scale:float = 0.125
@export var pickup_type:Pickup = Pickup.UNASSIGNED
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
		"texture": "res://Scenes/Pickups/Pickup_PNGS/Snipe Icon.png",
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
		"texture": "res://Scenes/Pickups/Pickup_PNGS/Spread Icon.png",
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
		"texture": "res://Scenes/Pickups/Pickup_PNGS/Repeat Icon.png",
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
		"texture": "res://Scenes/Pickups/Pickup_PNGS/Slug Icon.png",
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
		"texture": "res://Scenes/Pickups/Pickup_PNGS/Blade Icon.png",
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
	},
	Pickup.transformer: {
		"texture": "res://Scenes/Pickups/Pickup_PNGS/transformer1.png",
		"mods": {
			"bullet_speed": "-25%",
			"bullet_size": "+50%",
			"bullet_accuracy": "+20%"
		}
	},
	Pickup.radiator: { 
		"texture": "res://Scenes/Pickups/Pickup_PNGS/radiator1.png",
		"mods": {
			"bullet_accuracy": "-10%",
			"bullet_firing_rate": "-25%",
			"bullet_speed": "+10%",
			"stamina": "+1"
		}
	},
	Pickup.power_converter: {
		"texture": "res://Scenes/Pickups/Pickup_PNGS/power converter.png",
		"mods": {
			"bullet_damage": "-1",
			"dodge_speed": "+10%",
			"melee_damage": "+3",
		}
	},
	Pickup.power_diverter: {
		"texture": "res://Scenes/Pickups/Pickup_PNGS/power diverter.png",
		"mods": {
			"melee_damage": "-1",
			"bullet_speed": "+10%",
			"bullet_damage": "+3"
		}
	},
	Pickup.voltage_regulator: {
		"texture": "res://Scenes/Pickups/Pickup_PNGS/voltage regulator.png",
		"mods": {
			"bullet_accuracy": "+50%",
			"bullet_range": "+30%"
		}
	},
	Pickup.malware: {
		"texture": "res://Scenes/Pickups/Pickup_PNGS/malware.png",
		"mods": {
			"dodge_speed": "-10%",
			"bullet_accuracy": "-5%",
			"bullet_damage": "+3"
		}
	},
	Pickup.overclock: {
		"texture": "res://Scenes/Pickups/Pickup_PNGS/overclock.png",
		"mods": {
			"bullet_firing_rate": "+10%",
			"bullet_speed": "+15%",
			"dodge_speed": "+15%"
		}
	},
	Pickup.virus: {
		"texture": "res://Scenes/Pickups/Pickup_PNGS/virus.png",
		"mods": {
			"bullet_accuracy": "-10%",
			"bullet_size": "-20%",
			"bullet_piercing": "+1"
		}
	},
	Pickup.ram: {
		"texture": "res://Scenes/Pickups/Pickup_PNGS/ram.png",
		"mods": {
			"melee_damage": "+1",
			"dodge_speed": "+25%"
		}
	}
}

func _on_pickup_detector_body_entered(body: Node2D) -> void:
	if body is Player:
		body.add_mods(mods)
		queue_free()

func _ready() -> void:
	if pickup_type == Pickup.UNASSIGNED:
		push_warning("unassigned pickup: ", self)
	else:
		var entry:Dictionary = pickups[pickup_type]
		texture = load(entry["texture"])
		mods = entry["mods"]
	if texture != null:
		sprite.texture = texture
		sprite.scale = Vector2(tex_scale, tex_scale)
	else:
		sprite.modulate = Color.RED
