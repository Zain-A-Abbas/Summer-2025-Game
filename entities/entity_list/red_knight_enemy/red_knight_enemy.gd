class_name RedKnightEnemy
extends Enemy

@export var instant_turn_hp_amount: int = 40
@export var player_pushback: float = 1600.0
@export var aggro_range: Array[float] = [3.0, 9.0]
@export var active_radius: float = 15.0
@export var swing_move_speed: float = 3000.0
@export var distance_to_swing: float = 7.0

var direction: Vector3

@onready var thrust: AttackObject = %basic_attack
@onready var ray_cast: RayCast3D = %ray_cast
@onready var shield_icon: Sprite3D = %ShieldIcon

func prepare_states():	
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", RedKnightEnemyIdle.new(self)),
		StateInitializer.new(&"Block", RedKnightEnemyBlock.new(self, hurtbox, ray_cast)),
		StateInitializer.new(&"Swing", RedKnightEnemySwing.new(self, thrust)),
		StateInitializer.new(&"Death", DeathState.new(
			self, 
			"basic_enemy_animation_library/death", # change later
			death_state_duration
			))
	]
	
	state_machine.assign_states(enemy_states)

func _on_hurtbox_hit_received(attack_object: AttackObject, invin: bool) -> void:
	if !invin:
		play_sound_fx( &"damaged")
		hurt_effect()
		resolve_hit(attack_object)
	else:
		play_sound_fx(&"shield_block")
		
		player.deflect_velocity = direction * player_pushback
		player.deflect_decay = player_pushback * 4.0
		

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	RunStats.enemies_killed += 1
	enemy_killed.emit(self)
	hurtbox.set_collision_mask_value(2, 0)
	shield_icon.hide()
	state_machine.change_state(&"Death", {"summoned": args.has("summoned")})
