class_name EnemyScaler
extends Node

# Scale enemy components, attack damage, and add extra effects

func scale_enemy(enemy: Enemy, multipier: float, args: Dictionary[String, Variant] = {}):
	if enemy.type == Enemy.EnemyType.CARD:
		scale_card(enemy, multipier, args)
	elif enemy.type == Enemy.EnemyType.CATERPILLAR:
		pass
	elif enemy.type == Enemy.EnemyType.FLOWER:
		pass
	elif enemy.type == Enemy.EnemyType.MAD_HATTER:
		pass
	elif enemy.type == Enemy.EnemyType.MOUSE:
		pass
	elif enemy.type == Enemy.EnemyType.RED_KNIGHT:
		pass
	else: #JABBERWOCK
		pass

## by default, scale health and damage
func scale_card(card: BasicEnemy, multipier: float, args: Dictionary[String, Variant] = {}):
	card.basic_attack.attack_effects[0].damage = roundf(float(card.basic_attack.attack_effects[0].damage) *  multipier)
	
	# add attack effects: burn, para, slow

func scale_caterpillar(caterpillar: CaterpillarEnemy, multipier: float, args: Dictionary[String, Variant] = {}):
	pass

	# do not add attack effects
	# add a chance to increase speed

func scale_flower(flower: FlowerEnemy, multipier: float, args: Dictionary[String, Variant] = {}):
	pass
	
	# chance to add slow effect

func scale_mad_hatter(hatter: MadHatterEnemy, multiplier: float, args: Dictionary[String, Variant] = {}):
	pass
	
	# decrease summon time
	# increase summon hp cancel threshold

func scale_mouse(mouse: MouseEnemy, multiplier: float, args: Dictionary[String, Variant] = {}):
	pass
	
	# add attack effects: burn, slow
	# increase chance paralysis chance

func scale_red_knight(knight: RedKnightEnemy, multiplier: float, args: Dictionary[String, Variant] = {}):
	pass
	
	# add attack effects: burn, slow, para
	# slightly increase move_speed
	
func scale_jabberwock(jabberwock: JabberwockBoss, multiplier: float, args: Dictionary[String, Variant] = {}):
	pass
	
	# pending
