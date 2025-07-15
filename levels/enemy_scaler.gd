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

func scale_card(card: BasicEnemy, multipier: float, args: Dictionary[String, Variant] = {}):
	# Damage Scaling
	card.basic_attack.attack_effects[0].damage = roundf(float(card.basic_attack.attack_effects[0].damage) *  multipier)
	
	
