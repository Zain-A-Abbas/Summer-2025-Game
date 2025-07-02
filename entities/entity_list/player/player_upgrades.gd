extends RefCounted
class_name PlayerUpgrades

signal upgrades_updated

enum UpgradeTypes {
	PARRY_FRAME_BONUS,
	DAMAGE_BONUS,
	PARRY_DAMAGE_BONUS,
	EXTRA_HEALTH,
	EXTRA_STAMINA
}

const PARRY_BONUS_LIMIT: int = 5
const PARRY_BONUS_AMOUNT: float = 0.02

const EXTRA_DAMAGE_LIMIT: int = 8
const EXTRA_DAMAGE_AMOUNT: int = 1

const EXTRA_PARRY_DAMAGE_LIMIT: int = 5
const EXTRA_PARRY_DAMAGE_AMOUNT: float = 0.2

const EXTRA_HP_LIMIT: int = 10
const EXTRA_HP_AMOUNT: int = 10

const EXTRA_STAMINA_LIMIT: int = 4
const EXTRA_STAMINA_AMOUNT: int = 25

# Every 1 means 0.02 more seconds of parrying, or effectively a bit
# over 1 parry frame
var extra_parry_time: int = 0

var extra_damage: int = 0

var extra_parry_damage: int = 0

var extra_hp: int = 0

var extra_stamina: int = 0

func obtain_upgrade(type: UpgradeTypes, amount: int = 1) -> bool:
	match type:
		UpgradeTypes.PARRY_FRAME_BONUS:
			return obtain_parry_time_upgrade(amount)
		UpgradeTypes.DAMAGE_BONUS:
			return obtain_damage_upgrade(amount)
		UpgradeTypes.PARRY_DAMAGE_BONUS:
			return obtain_parry_damage_upgrade(amount)
		UpgradeTypes.EXTRA_HEALTH:
			return obtain_hp_upgrade(amount)
		UpgradeTypes.EXTRA_STAMINA:
			return obtain_stamina_upgrade(amount)
	
	return false

func obtain_parry_time_upgrade(amount: int = 1) -> bool:
	if extra_parry_time >= PARRY_BONUS_LIMIT:
		return false
	extra_parry_time = clampi(extra_parry_time + amount, 0, PARRY_BONUS_LIMIT)
	upgrades_updated.emit()
	return true

func obtain_damage_upgrade(amount: int = 1) -> bool:
	if extra_damage >= EXTRA_DAMAGE_LIMIT:
		return false
	extra_damage = clampi(extra_damage + amount, 0, EXTRA_DAMAGE_LIMIT)
	upgrades_updated.emit()
	return true

func obtain_parry_damage_upgrade(amount: int = 1) -> bool:
	if extra_parry_damage >= EXTRA_PARRY_DAMAGE_LIMIT:
		return false
	extra_parry_damage = clampi(extra_parry_damage + amount, 0, EXTRA_PARRY_DAMAGE_LIMIT)
	upgrades_updated.emit()
	return true

func obtain_hp_upgrade(amount: int = 1) -> bool:
	if extra_hp >= EXTRA_HP_LIMIT:
		return false
	extra_hp = clampi(extra_hp + amount, 0, EXTRA_HP_LIMIT)
	upgrades_updated.emit()
	return true

func obtain_stamina_upgrade(amount: int = 1) -> bool:
	if extra_stamina >= EXTRA_STAMINA_LIMIT:
		return false
	extra_stamina = clampi(extra_stamina + amount, 0, EXTRA_STAMINA_LIMIT)
	upgrades_updated.emit()
	return true
