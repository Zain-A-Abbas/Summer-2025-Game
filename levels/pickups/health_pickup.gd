extends Pickup

func pickup_effect(_player: Player):
	_player.heal(_player.health_component.max_health)
