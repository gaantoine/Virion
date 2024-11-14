extends Node2D  

var is_locked = true

func _ready():
    pass

func unlock():
    if is_locked:
        is_locked = false
        print("The door is now unlocked!")
       
func _on_Player_interact_with_door(player):
    if player.has_key:
        unlock()
