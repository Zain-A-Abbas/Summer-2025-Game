extends TextureRect
class_name UpgradeIcon

@onready var upgrade_label: Label = %UpgradeLabel

@export var type: PlayerUpgrades.UpgradeTypes = PlayerUpgrades.UpgradeTypes.PARRY_FRAME_BONUS

var max: int = 0
var current: int = 0

func _ready() -> void:
	match type:
		PlayerUpgrades.UpgradeTypes.PARRY_FRAME_BONUS:
			max = PlayerUpgrades.BASE_PARRY_BONUS_LIMIT
		PlayerUpgrades.UpgradeTypes.DAMAGE_BONUS:
			max = PlayerUpgrades.BASE_EXTRA_DAMAGE_LIMIT
		PlayerUpgrades.UpgradeTypes.PARRY_DAMAGE_BONUS:
			max = PlayerUpgrades.BASE_EXTRA_PARRY_DAMAGE_LIMIT
		PlayerUpgrades.UpgradeTypes.EXTRA_HEALTH:
			max = PlayerUpgrades.BASE_EXTRA_HP_LIMIT
		PlayerUpgrades.UpgradeTypes.EXTRA_STAMINA:
			max = PlayerUpgrades.BASE_EXTRA_STAMINA_LIMIT
	
	set_upgrade_amount(0)

func set_upgrade_amount(amount: int, new_max: int = 1):
	current = amount
	if new_max > 1:
		max = new_max
	upgrade_label.text = "%s / %s" % [current, max]
