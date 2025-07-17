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

const BASE_PARRY_BONUS_LIMIT: int = 5
const PARRY_BONUS_AMOUNT: float = 0.02

const BASE_EXTRA_DAMAGE_LIMIT: int = 8
const EXTRA_DAMAGE_AMOUNT: int = 1

const BASE_EXTRA_PARRY_DAMAGE_LIMIT: int = 5
const EXTRA_PARRY_DAMAGE_AMOUNT: float = 0.2

const BASE_EXTRA_HP_LIMIT: int = 10
const EXTRA_HP_AMOUNT: int = 10

const BASE_EXTRA_STAMINA_LIMIT: int = 4
const EXTRA_STAMINA_AMOUNT: int = 25

# Every 1 means 0.02 more seconds of parrying, or effectively a bit
# over 1 parry frame
var extra_parry_limit: int = BASE_PARRY_BONUS_LIMIT
var extra_parry_time: int = 0

var extra_damage_limit: int = BASE_EXTRA_DAMAGE_LIMIT
var extra_damage: int = 0

var extra_parry_damage_limit: int =  BASE_EXTRA_PARRY_DAMAGE_LIMIT
var extra_parry_damage: int = 0

var extra_hp_limit: int =  BASE_EXTRA_HP_LIMIT
var extra_hp: int = 0

var extra_stamina_limit: int = BASE_EXTRA_STAMINA_LIMIT
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
	if extra_parry_time >= extra_parry_limit:
		return false
	extra_parry_time = clampi(extra_parry_time + amount, 0, extra_parry_limit)
	upgrades_updated.emit()
	return true

func obtain_damage_upgrade(amount: int = 1) -> bool:
	if extra_damage >= extra_damage_limit:
		return false
	extra_damage = clampi(extra_damage + amount, 0, extra_damage_limit)
	upgrades_updated.emit()
	return true

func obtain_parry_damage_upgrade(amount: int = 1) -> bool:
	if extra_parry_damage >= extra_parry_damage_limit:
		return false
	extra_parry_damage = clampi(extra_parry_damage + amount, 0, extra_parry_damage_limit)
	upgrades_updated.emit()
	return true

func obtain_hp_upgrade(amount: int = 1) -> bool:
	if extra_hp >= extra_hp_limit:
		return false
	extra_hp = clampi(extra_hp + amount, 0, extra_hp_limit)
	upgrades_updated.emit()
	return true

func obtain_stamina_upgrade(amount: int = 1) -> bool:
	if extra_stamina >= extra_stamina_limit:
		return false
	extra_stamina = clampi(extra_stamina + amount, 0, extra_stamina_limit)
	upgrades_updated.emit()
	return true

func increase_upgrade_limits():
	extra_parry_limit += 2
	extra_damage_limit += 3
	extra_parry_damage_limit += 3
	extra_hp_limit += 5
	extra_stamina_limit += 2
	
	upgrades_updated.emit()
