class_name JabberwockBossShoot
extends EnemyState

const BOMB = preload("res://entities/entity_list/flower_enemy/flower_enemy_bomb/flower_enemy_bomb.tscn")
const SEED = preload("res://entities/entity_list/caterpillar_enemy/caterpillar_enemy_seed/caterpillar_enemy_seed.tscn")
const ROTATION_SPEED: float = deg_to_rad(1.15)
const BREATH_TOGGLE_OFF_TIME: float = 0.2
const BREATH_TOGGLE_ON_TIME: float = 0.3
const ACTION_LIST: Array[StringName] = [&"Bomb", &"Seed", &"Breath"]
const ACTION_DURATIONS: Array[float] = [0.5, 0.3, BREATH_TOGGLE_ON_TIME * 8]
const ACTION_COOLDOWNS: Array[float] = [0.3, 0.2, 1.3]
#const ACTION_RAGE_THRESHOLD: Array[int] = [0, 100, 200]

const BREATH_WARNING_TRACKERS: Array[float] = [1.5, 2.0]
const SHOOT_WARNING_TRACKERS: Array[float] = [0.25, 0.5]
const BREATH_TIMES: Array[float] = [2.35, 3.0]
const SEED_BOMB_TIMES: Array[float] = [0.5, 0.85]

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

var delta_count: float = 0.0
var shoot_times: Array[float] = [0.0, 0.0]
var breath_toggle_count: float = 0.0


func _init(new_enemy: Enemy, rage: JabberwockBossRageComponent, atk: AttackObject) -> void:
	enemy = new_enemy
	rage_component = rage
	breath = atk

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	breath_toggle_count = 0.0
	warning_trackers.fill(0.0)
	
	attack_activated = false
	warning_hidden = false
	warning_shown = false
	breath.hitbox.monitorable = false
	
	action_index = randi_range(2, 2)
	action = ACTION_LIST[action_index]
	
	print("Action is")
	print(action)
	if action == &"Breath":
		warning_times = BREATH_WARNING_TRACKERS
		shoot_times = BREATH_TIMES
		enemy.animation_tree["parameters/breath_oneshot/request"] = 1
	elif action == &"Seed" || action == &"Bomb":
		warning_times = SHOOT_WARNING_TRACKERS
		shoot_times = SEED_BOMB_TIMES
		enemy.animation_tree["parameters/shoot_oneshot/request"] = 1
	else:
		push_error("Jabberwock using invalid action on shoot state")
	
	enemy.face_direction(face_player())

func st_physics_process(delta: float) -> void:
	delta_count += delta
	for n in warning_trackers.size():
		warning_trackers[n] += delta
		
	rage_component.decay_rage(delta)
	
	if warning_trackers[0] > warning_times[0] && !warning_shown:
		enemy.attack_indicator_animator.play("show_indicator")
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
			var seed: CaterpillarEnemySeed = SEED.instantiate()
			enemy.projectiles.add_child(seed)
			seed.global_position = enemy.projectile_spawnpoint.global_position
			seed.initialize_seed(false, enemy.projectile_spawnpoint.global_position.direction_to(enemy.player.position), enemy.projectiles, enemy.seed_damage)
		elif action == &"Breath":
			enemy.lightning_breath_particles.emitting = true
	
	if action == &"Breath" && delta_count >= shoot_times[0]:
		lightning_breath(delta)
	
	if delta_count >= shoot_times[1]:
		if enemy.can_combo():
			rage_component.consume_rage()
			state_machine.change_state(&"Sweep", {"from_shoot": ACTION_COOLDOWNS[action_index]})
		return state_machine.change_state(&"Idle", {"cooldown": ACTION_COOLDOWNS[action_index]})

func lightning_breath(delta: float) -> void:
	# toggle hitbox on and off in intervals
	breath_toggle_count += delta
	breath.hitbox.monitorable = delta_count < shoot_times[1]
	
	#if breath_toggle_count > BREATH_TOGGLE_ON_TIME:
	#	breath_toggle_count = 0.0

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
