class_name JabberwockBossShoot
extends EnemyState

const BOMB = preload("res://entities/entity_list/flower_enemy/flower_enemy_bomb/flower_enemy_bomb.tscn")
const SEED = preload("res://entities/entity_list/caterpillar_enemy/caterpillar_enemy_seed/caterpillar_enemy_seed.tscn")
const ROTATION_SPEED: float = deg_to_rad(2.2)
const SEED_DISTANCE: float = 10.5
const BOMB_DISTANCE: float = 16
const ACTION_LIST: Array[StringName] = [&"Bomb", &"Seed", &"Breath"]
const ACTION_COOLDOWNS: Array[float] = [0.3, 0.35, 0.5]
const BREATH_TOGGLE_OFF_TIME: float = 0.09
const BREATH_TOGGLE_ON_TIME: float = 0.15

const BREATH_WARNING_TRACKERS: Array[float] = [0.5, 1.5]
const SHOOT_WARNING_TRACKERS: Array[float] = [0.25, 0.5]
const BREATH_TIMES: Array[float] = [1.41, 2.0]
const SEED_BOMB_TIMES: Array[float] = [0.37, 0.7028]

var rage_component: JabberwockBossRageComponent
var breath: AttackObject

var attack_activated: bool= false
var warning_trackers: Array[float] = [0.0, 0.0]
var warning_times: Array[float] = [0.0, 0.0]
var warning_shown: bool = false
var warning_hidden: bool = false

var action: StringName
var action_index: int
var direction: Vector3
var from_swipe: bool = false
var cooldown: float = 0.0
var sound_played: bool = false

var delta_count: float = 0.0
var shoot_times: Array[float] = [0.0, 0.0]
var breath_toggle_count: float = 0.0
var n_seeds: int = 1
var seed_directions: Array[Vector3]
var base_seed_direction: Vector3

func _init(new_enemy: Enemy, rage: JabberwockBossRageComponent, atk: AttackObject) -> void:
	enemy = new_enemy
	rage_component = rage
	breath = atk

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	var distance: float = distance_to_player()
	
	delta_count = 0.0
	breath_toggle_count = 0.0
	warning_trackers.fill(0.0)
	seed_directions = []
	
	sound_played = false
	attack_activated = false
	warning_hidden = false
	warning_shown = false
	breath.hitbox.monitorable = false
	from_swipe = false
	
	if args.has("from_swipe"):
		from_swipe = true
		action = &"Bomb"
		cooldown = ACTION_COOLDOWNS[0] + args["from_swipe"]
	else:
		if distance < SEED_DISTANCE:
			action_index = 2
		elif distance >= SEED_DISTANCE && distance < BOMB_DISTANCE:
			action_index = 1
		else:
			action_index = 0
		
		action = ACTION_LIST[action_index]
		cooldown = ACTION_COOLDOWNS[action_index]
		
	if action == &"Breath":
		warning_times = BREATH_WARNING_TRACKERS
		shoot_times = BREATH_TIMES
		enemy.action_animator.play("jabberwock/breath")
		enemy.play_sound_fx(&"breath_roar")
	elif action == &"Seed" || action == &"Bomb":
		warning_times = SHOOT_WARNING_TRACKERS
		shoot_times = SEED_BOMB_TIMES
		enemy.action_animator.play("jabberwock/shoot")
	else:
		push_error("Jabberwock using invalid action on shoot state")
		
	if action == &"Seed":
		initialize_seed_directions()
	
	enemy.face_direction(face_player())

func st_physics_process(delta: float) -> void:
	delta_count += delta
	for n in warning_trackers.size():
		warning_trackers[n] += delta
		
	rage_component.decay_rage(delta)
	
	if warning_trackers[0] > warning_times[0] && !warning_shown:
		enemy.attack_indicator_animator.play("show_indicator")
		if action != &"Breath":
			enemy.play_sound_fx(&"shoot_roar")
		warning_shown = true
	
	if warning_trackers[1] > warning_times[1] && !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
		warning_hidden = true
	
	if delta_count >= shoot_times[0] && !attack_activated:
		attack_activated = true
		
		if action == &"Bomb":
			var bomb: FlowerEnemyBomb = BOMB.instantiate()
			enemy.projectiles.add_child(bomb)
			bomb.initialize_bomb(enemy.projectile_spawnpoint.global_position, enemy.player.global_position, enemy.bomb_damage)
		elif action == &"Seed":
			for n in n_seeds:
				var seed: CaterpillarEnemySeed = SEED.instantiate()
				enemy.projectiles.add_child(seed)
				seed.global_position = enemy.projectile_spawnpoint.global_position
				seed.initialize_seed(false, seed_directions[n], enemy.projectiles, enemy.seed_damage)
		elif action == &"Breath":
			enemy.lightning_breath_particles.emitting = true
			
		if action != &"Breath":
			enemy.play_sound_fx(&"shoot")
	
	if action == &"Breath" && delta_count >= shoot_times[0]:
		lightning_breath(delta)
		if !sound_played:
			enemy.play_sound_fx(&"breath1")
			enemy.play_sound_fx(&"breath2")
			sound_played = true
	
	if delta_count >= shoot_times[1]:
		if action == &"Breath" && enemy.can_combo() && !from_swipe:
			rage_component.consume_rage()
			return state_machine.change_state(&"Swipe", {"from_shoot": cooldown})
		return state_machine.change_state(&"Idle", {"cooldown": cooldown})

func lightning_breath(delta: float) -> void:
	# toggle hitbox on and off in intervals
	breath_toggle_count += delta
	breath.hitbox.monitorable = breath_toggle_count < BREATH_TOGGLE_OFF_TIME
	
	if breath_toggle_count > BREATH_TOGGLE_ON_TIME:
		breath_toggle_count = 0.0

	# rotate to player slowly
	direction = face_player()
	var forward_direction: Vector3 = enemy.global_transform.basis.z
	var side_vector: Vector3 = forward_direction.rotated(Vector3(0, 1, 0), deg_to_rad(90))
	
	if side_vector.dot(direction) > 0.0:
		enemy.rotation.y += ROTATION_SPEED
	elif side_vector.dot(direction) < 0.0:
		enemy.rotation.y -= ROTATION_SPEED

	# advance towards player
	enemy.velocity = direction * enemy.movement_component.move_speed * delta
	enemy.move_and_slide()

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	if !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
		
	breath.hitbox.monitorable = false

func initialize_seed_directions():
	if enemy.health_component.current_health <= enemy.health_component.max_health / 2:
		n_seeds = randi_range(2, 3)
	else:
		n_seeds = 1
	
	#n_seeds = 3
	for n in n_seeds:
		seed_directions.append(Vector3.ZERO)
	
	base_seed_direction = enemy.projectile_spawnpoint.global_position.direction_to(enemy.player.position)
	seed_directions[0] = base_seed_direction
	match n_seeds:
		3:
			seed_directions[1] = base_seed_direction.rotated(Vector3.UP, deg_to_rad(30.0))
			seed_directions[2] = base_seed_direction.rotated(Vector3.UP, deg_to_rad(-30.0))
		2:
			seed_directions[0] = base_seed_direction.rotated(Vector3.UP, deg_to_rad(15.0))
			seed_directions[1] = base_seed_direction.rotated(Vector3.UP, deg_to_rad(-15.0))
