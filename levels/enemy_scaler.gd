class_name EnemyScaler
extends Node

# Scale enemy components, attack damage, and add extra effects
const ADD_EFFECT_CHANCE: float = 1.0
const ATK_EFFECTS: Array[AttackEffect.AttackEffectType] = [
	AttackEffect.AttackEffectType.BURN,
	AttackEffect.AttackEffectType.PARALYSIS,
	AttackEffect.AttackEffectType.BLEED
]

var effect: AttackEffect.AttackEffectType
var level_manager: LevelManager

func _init(manager: LevelManager):
	level_manager = manager

## by default, scale health and damage
func scale_enemy(enemy: Enemy, args: Dictionary[String, Variant]):
	# scale health
	enemy.health_component.max_health = ceilf(float(enemy.health_component.max_health) * args["hp_multiplier"])
	enemy.health_component.set_current_health(enemy.health_component.max_health)
	
	enemy.enemy_hp_bar.max_value = enemy.health_component.max_health
	enemy.enemy_hp_bar.value = enemy.health_component.current_health
	
	# scale everything else
	if enemy.type == Enemy.EnemyType.CARD:
		scale_card(enemy, args)
	elif enemy.type == Enemy.EnemyType.CATERPILLAR:
		scale_caterpillar(enemy, args)
	elif enemy.type == Enemy.EnemyType.FLOWER:
		scale_flower(enemy, args)
	elif enemy.type == Enemy.EnemyType.MAD_HATTER:
		scale_mad_hatter(enemy, args)
	elif enemy.type == Enemy.EnemyType.MOUSE:
		scale_mouse(enemy, args)
	elif enemy.type == Enemy.EnemyType.RED_KNIGHT:
		scale_red_knight(enemy, args)
	else: #JABBERWOCK
		scale_jabberwock(enemy, args)
		
func scale_card(card: BasicEnemy, args: Dictionary[String, Variant]):
	card.basic_attack.attack_effects[0].damage = ceilf(float(card.basic_attack.attack_effects[0].damage) * args["dmg_multiplier"])
	
	# add attack effects: burn, para, bleed
	if args.has("run") && randf() <= ADD_EFFECT_CHANCE:
		effect = ATK_EFFECTS.pick_random()
		#print(effect)
		create_effect_parameters(effect, args)
		card.basic_attack.add_attack_effect(effect, args)

func scale_caterpillar(caterpillar: CaterpillarEnemy, args: Dictionary[String, Variant]):
	caterpillar.seed_damage = ceilf(float(caterpillar.seed_damage) * args["dmg_multiplier"])

	# increase speed
	if args.has("run"):
		caterpillar.movement_component.set_move_speed(caterpillar.movement_component.move_speed * 1.10)

func scale_flower(flower: FlowerEnemy, args: Dictionary[String, Variant]):
	flower.bomb_damage = ceilf(float(flower.bomb_damage) * args["dmg_multiplier"])

func scale_mad_hatter(hatter: MadHatterEnemy, args: Dictionary[String, Variant]):	
	# increase summon hp cancel threshold
	hatter.summon_cancel_hp_amount = ceilf(float(hatter.summon_cancel_hp_amount) * args["hp_multiplier"])

	# decrease summon time
	if args.has("run"):
		hatter.summon_timestamp *= 0.70

func scale_mouse(mouse: MouseEnemy, args: Dictionary[String, Variant]):
	mouse.pounce.attack_effects[0].damage = ceilf(float(mouse.pounce.attack_effects[0].damage) * args["dmg_multiplier"])
	
	# increase paralysis chance
	mouse.pounce.attack_effects[1].stun_chance = 0.35
		
	# add attack effects: burn, bleed
	if args.has("run") && randf() <= ADD_EFFECT_CHANCE:
		var atk_effects_temp: Array[AttackEffect.AttackEffectType] = ATK_EFFECTS.duplicate()
		atk_effects_temp.remove_at(atk_effects_temp.find(AttackEffect.AttackEffectType.PARALYSIS))
		effect = atk_effects_temp.pick_random()
		
		create_effect_parameters(effect, args)
		mouse.pounce.add_attack_effect(effect, args)

func scale_red_knight(knight: RedKnightEnemy, args: Dictionary[String, Variant]):
	knight.thrust.attack_effects[0].damage = ceilf(float(knight.thrust.attack_effects[0].damage) * args["dmg_multiplier"])
	
	# add attack effects: burn, bleed
	if args.has("run") && randf() <= ADD_EFFECT_CHANCE:
		var atk_effects_temp: Array[AttackEffect.AttackEffectType] = ATK_EFFECTS.duplicate()
		atk_effects_temp.remove_at(atk_effects_temp.find(AttackEffect.AttackEffectType.PARALYSIS))
		effect = atk_effects_temp.pick_random()
		
		create_effect_parameters(effect, args)
		knight.thrust.add_attack_effect(effect, args)
	
	# slightly increase move_speed
	knight.movement_component.set_move_speed(knight.movement_component.move_speed * 1.15)
	
func scale_jabberwock(jabberwock: JabberwockBoss, args: Dictionary[String, Variant]):
	jabberwock.bomb_damage = ceilf(jabberwock.bomb_damage * args["dmg_multiplier"])
	jabberwock.seed_damage = ceilf(jabberwock.seed_damage * args["dmg_multiplier"])
	jabberwock.breath.attack_effects[0].damage = ceilf(jabberwock.breath.attack_effects[0].damage * args["dmg_multiplier"])
	jabberwock.swipe.attack_effects[0].damage = ceilf(jabberwock.swipe.attack_effects[0].damage * args["dmg_multiplier"])
	jabberwock.swipe_mirrored.attack_effects[0].damage = ceilf(jabberwock.swipe_mirrored.attack_effects[0].damage * args["dmg_multiplier"])
	jabberwock.sweep.attack_effects[0].damage = ceilf(jabberwock.sweep.attack_effects[0].damage * args["dmg_multiplier"])
	
	# add another stack of bleed to swipes
	jabberwock.swipe.add_attack_effect(AttackEffect.AttackEffectType.BLEED, args)
	jabberwock.swipe_mirrored.add_attack_effect(AttackEffect.AttackEffectType.BLEED, args)

	var args_dupe: Dictionary[String, Variant] = args.duplicate()

	# add burn effect to breath
	create_effect_parameters(AttackEffect.AttackEffectType.BURN, args_dupe)
	jabberwock.breath.add_attack_effect(AttackEffect.AttackEffectType.BURN, args_dupe)
	
	# add burn and para to swipes
	if args.has("run") && randf() <= ADD_EFFECT_CHANCE:
		args_dupe = args.duplicate()
		var index: int = randi_range(0, 1)
		effect = ATK_EFFECTS[index]
		create_effect_parameters(effect, args_dupe)
		jabberwock.swipe.add_attack_effect(effect, args_dupe)
		
		args_dupe = args.duplicate()
		index = randi_range(0, 1)
		effect = ATK_EFFECTS[index]
		create_effect_parameters(effect, args_dupe)
		jabberwock.swipe_mirrored.add_attack_effect(effect, args_dupe)

func create_effect_parameters(effect_type: AttackEffect.AttackEffectType, args: Dictionary[String, Variant]):
	if effect_type == AttackEffect.AttackEffectType.BURN:
		args["duration"] = randf_range(1.0, 3.2)
	elif effect_type == AttackEffect.AttackEffectType.PARALYSIS:
		args["duration"] = randf_range(0.6, 1.7)
		args["chance"] = 1.0 #randf_range(0.20, 1.0)
