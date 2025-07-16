class_name PlayerUI
extends CanvasLayer

@onready var hp_under_bar: ProgressBar = %HPUnderBar
@onready var hp_bar: ProgressBar = %HPBar
@onready var stamina_under_bar: ProgressBar = %StaminaUnderBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var control_shake_component: ControlShakeComponent = %ControlShakeComponent
@onready var parry_icons: Array[TextureRect] = [%ParryIcon, %ParryIcon2, %ParryIcon3]
@onready var money_label: Label = %MoneyLabel
@onready var upgrade_icons_container: VBoxContainer = %UpgradeIconsContainer
@onready var upgrade_icons: Array[UpgradeIcon] = []

var player: Player = null

func _ready() -> void:
	for icon in parry_icons:
		icon.visible = false
	
	for child in upgrade_icons_container.get_children():
		if child is UpgradeIcon:
			upgrade_icons.append(child)

# Runs every frame as stamina naturally regens
func _physics_process(delta: float) -> void:
	if !player:
		return
	stamina_bar.value = player.stamina
	for n in parry_icons.size():
		parry_icons[n].visible = player.parry_counter > n

func update_money(amount: int):
	money_label.update_money_indicator(amount)

# Runs when the player variable has to be refreshed
func refresh_player(current_player: Player):
	player = current_player
	set_hp_immediate(player)
	player.player_damage_taken.connect(player_damage_taken)
	stamina_bar.max_value = current_player.max_stamina

func update_upgrades(current_player: Player):
	upgrade_icons[0].set_upgrade_amount(current_player.upgrades.extra_parry_time, current_player.upgrades.extra_parry_limit)
	upgrade_icons[1].set_upgrade_amount(current_player.upgrades.extra_damage, current_player.upgrades.extra_damage_limit)
	upgrade_icons[2].set_upgrade_amount(current_player.upgrades.extra_parry_damage, current_player.upgrades.extra_parry_damage_limit)
	upgrade_icons[3].set_upgrade_amount(current_player.upgrades.extra_hp, current_player.upgrades.extra_hp_limit)
	upgrade_icons[4].set_upgrade_amount(current_player.upgrades.extra_stamina, current_player.upgrades.extra_stamina_limit)
	set_hp_immediate(player)
	stamina_bar.max_value = current_player.max_stamina
	stamina_bar.custom_minimum_size.x = 100 * (current_player.max_stamina / 100.0)

func player_damage_taken(current_player: Player, damage: int):
	control_shake_component.begin_trauma(10, 20)
	hp_under_bar.value = hp_bar.value
	hp_bar.value = current_player.health_component.current_health
	
	var hp_tween: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	hp_tween.tween_property(hp_under_bar, "value", hp_bar.value, 0.2).set_delay(0.2)

func player_hp_recovered(current_player: Player):
	hp_bar.value = current_player.health_component.current_health
	hp_under_bar.value = current_player.health_component.current_health

func set_hp_immediate(current_player: Player):
	var hp_bar_length: float = 200 * (current_player.health_component.max_health / 100.0)
	hp_bar.custom_minimum_size.x = hp_bar_length
	hp_under_bar.custom_minimum_size.x = hp_bar_length
	hp_bar.value = current_player.health_component.current_health
	hp_under_bar.value = current_player.health_component.current_health
