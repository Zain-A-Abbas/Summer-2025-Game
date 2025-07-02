@tool
extends Pickup
class_name MoneyPickup

const MONEY_RANGE: Array[int] = [20, 40]
const GRAVITY: float = 0.98


func pickup_effect(player: Player):
	player.gain_money(randi_range(MONEY_RANGE[0], MONEY_RANGE[1]))

func _physics_process(delta: float) -> void:
	super(delta)
