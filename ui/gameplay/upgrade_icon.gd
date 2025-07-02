extends TextureRect
class_name UpgradeIcon

@onready var upgrade_label: Label = %UpgradeLabel

@export var type: PlayerUpgrades.UpgradeTypes = PlayerUpgrades.UpgradeTypes.PARRY_FRAME_BONUS

var max: int = 0
var current: int = 0

func _ready() -> void:
	match type:
		PlayerUpgrades.UpgradeTypes.PARRY_FRAME_BONUS:
			max = PlayerUpgrades.PARRY_BONUS_LIMIT
		PlayerUpgrades.UpgradeTypes.DAMAGE_BONUS:
			max = PlayerUpgrades.EXTRA_DAMAGE_LIMIT
		PlayerUpgrades.UpgradeTypes.PARRY_DAMAGE_BONUS:
			max = PlayerUpgrades.EXTRA_PARRY_DAMAGE_LIMIT
		PlayerUpgrades.UpgradeTypes.EXTRA_HEALTH:
			max = PlayerUpgrades.EXTRA_HP_LIMIT
		PlayerUpgrades.UpgradeTypes.EXTRA_STAMINA:
			max = PlayerUpgrades.EXTRA_STAMINA_LIMIT
	
	set_upgrade_amount(0)

func set_upgrade_amount(amount: int):
	current = amount
	upgrade_label.text = "%s / %s" % [current, max]
