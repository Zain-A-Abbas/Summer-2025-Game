class_name PlayerUI
extends CanvasLayer

@onready var hp_under_bar: ProgressBar = %HPUnderBar
@onready var hp_bar: ProgressBar = %HPBar
@onready var stamina_under_bar: ProgressBar = %StaminaUnderBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var control_shake_component: ControlShakeComponent = %ControlShakeComponent
@onready var parry_icons: Array[TextureRect] = [%ParryIcon, %ParryIcon2, %ParryIcon3]

var player: Player = null

func _ready() -> void:
	for icon in parry_icons:
		icon.visible = false

# Runs every frame as stamina naturally regens
func _physics_process(delta: float) -> void:
	if !player:
		return
	stamina_bar.value = player.stamina
	for n in parry_icons.size():
		parry_icons[n].visible = player.parry_counter > n

# Runs when the player variable has to be refreshed
func refresh_player(level: LevelBase):
	var current_player: Player = level.player
	if !current_player:
		push_error("No player found in refresh_player()")
		return
	
	player = current_player
	
	set_hp_immediate(player)
	player.player_damage_taken.connect(player_damage_taken)

func player_damage_taken(current_player: Player, damage: int):
	control_shake_component.begin_trauma(10, 20)
	hp_under_bar.value = hp_bar.value
	hp_bar.value = current_player.health_component.current_health
	
	var hp_tween: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	hp_tween.tween_property(hp_under_bar, "value", hp_bar.value, 0.2).set_delay(0.2)

func player_hp_recovered(current_player: Player, recovery: int):
	pass

func set_hp_immediate(current_player: Player):
	hp_bar.value = current_player.health_component.current_health
	hp_under_bar.value = current_player.health_component.current_health
