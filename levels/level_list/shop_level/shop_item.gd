extends Node3D
class_name ShopItem

const UPGRADE_NAMES: Dictionary[PlayerUpgrades.UpgradeTypes, String] = {
	PlayerUpgrades.UpgradeTypes.PARRY_FRAME_BONUS: "Increase Parry Time",
	PlayerUpgrades.UpgradeTypes.DAMAGE_BONUS: "Extra Damage",
	PlayerUpgrades.UpgradeTypes.PARRY_DAMAGE_BONUS: "Extra Parry Damage",
	PlayerUpgrades.UpgradeTypes.EXTRA_HEALTH: "Extra Health",
	PlayerUpgrades.UpgradeTypes.EXTRA_STAMINA: "Extra Stamina",
}

const UPGRADE_PRICES: Dictionary[PlayerUpgrades.UpgradeTypes, int] = {
	PlayerUpgrades.UpgradeTypes.PARRY_FRAME_BONUS: 80,
	PlayerUpgrades.UpgradeTypes.DAMAGE_BONUS: 80,
	PlayerUpgrades.UpgradeTypes.PARRY_DAMAGE_BONUS: 80,
	PlayerUpgrades.UpgradeTypes.EXTRA_HEALTH: 80,
	PlayerUpgrades.UpgradeTypes.EXTRA_STAMINA: 80,
}

@export var type: PlayerUpgrades.UpgradeTypes = PlayerUpgrades.UpgradeTypes.PARRY_FRAME_BONUS
@export var price: int = 100

var bought: bool = false
var time: float = 0.0
var level_manager: LevelManager

@onready var item_sprite: Sprite3D = %ItemSprite
@onready var player_detection_area: Area3D = %PlayerDetectionArea
@onready var player_hit_area: Area3D = %PlayerHitArea
@onready var price_label: Label3D = %PriceLabel
@onready var name_label: Label3D = %NameLabel
@onready var sounds: Node3D = %Sounds

func _ready() -> void:
	price_label.modulate.a = 0.0
	price_label.outline_modulate.a = 0.0
	
	type = randi_range(0, PlayerUpgrades.UpgradeTypes.size() - 1)
	price = UPGRADE_PRICES[type] + randi_range(-20, 20)
	
	price_label.text = "%s GOLD" % price
	name_label.text = UPGRADE_NAMES[type]
	var texture_region: Vector2
	match type:
		PlayerUpgrades.UpgradeTypes.PARRY_FRAME_BONUS:
			texture_region = Vector2(0, 0)
		PlayerUpgrades.UpgradeTypes.DAMAGE_BONUS:
			texture_region = Vector2(64, 0)
		PlayerUpgrades.UpgradeTypes.PARRY_DAMAGE_BONUS:
			texture_region = Vector2(128, 0)
		PlayerUpgrades.UpgradeTypes.EXTRA_HEALTH:
			texture_region = Vector2(192, 0)
		PlayerUpgrades.UpgradeTypes.EXTRA_STAMINA:
			texture_region = Vector2(0, 64)
	
	item_sprite.texture.region.position = texture_region
	scale = Vector3(0.1, 0.1, 0.1)
	hide()

func _physics_process(delta: float) -> void:
	time += delta
	position.y = sin(time * 0.5) * 0.25

func initialize(_manager: LevelManager):
	level_manager = _manager
	
	show()
	var spawn_tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	spawn_tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.5)
	await spawn_tween.finished

func resolve_buy():
	if bought:
		return
	
	if level_manager.current_level_type == LevelBase.LevelType.SHOP:
		if level_manager.money < price:
			price_label.modulate = Color.RED
			var price_tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
			price_tween.tween_property(price_label, "modulate", Color.WHITE, 0.2)
			await price_tween.finished
			return
	
	var upgrade_suceeded: bool = level_manager.current_player.upgrades.obtain_upgrade(type, 1)
	if !upgrade_suceeded:
		return
	
	bought = true
	if level_manager.current_level_type == LevelBase.LevelType.SHOP:
		level_manager.money_gain(-price)
	
	var buy_tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	buy_tween.tween_property(self, "scale", Vector3(0.001, 0.001, 0.001), 0.5)
	await buy_tween.finished
	queue_free()

func show_price_label():
	if level_manager.current_level_type == LevelBase.LevelType.SHOP:
		var price_tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
		price_tween.tween_property(price_label, "position:y", 0.0, 0.2).from(-0.5)
		price_tween.tween_property(price_label, "modulate:a", 1.0, 0.2).from(0.0)
		price_tween.tween_property(price_label, "outline_modulate:a", 1.0, 0.2).from(0.0)

func hide_price_label():
	if level_manager.current_level_type == LevelBase.LevelType.SHOP:
		var price_tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
		price_tween.tween_property(price_label, "position:y", 0.5, 0.2).from(0.0)
		price_tween.tween_property(price_label, "modulate:a", 0.0, 0.2)
		price_tween.tween_property(price_label, "outline_modulate:a", 0.0, 0.2).from(1.0)

func _on_player_detection_area_body_entered(body: Node3D) -> void:
	if level_manager.current_level_type == LevelBase.LevelType.SHOP:
		show_price_label()

func _on_player_detection_area_body_exited(body: Node3D) -> void:
	if level_manager.current_level_type == LevelBase.LevelType.SHOP:
		hide_price_label()

func _on_player_hit_area_area_entered(area: Area3D) -> void:
	var name: String = "get_item_%d" % randi_range(1, 3)
	sounds.get_node(name).play()
	resolve_buy()
