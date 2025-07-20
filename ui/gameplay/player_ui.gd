class_name PlayerUI
extends CanvasLayer

@onready var gameplay_container: MarginContainer = %GameplayContainer
@onready var hp_under_bar: ProgressBar = %HPUnderBar
@onready var hp_bar: ProgressBar = %HPBar
@onready var stamina_under_bar: ProgressBar = %StaminaUnderBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var control_shake_component: ControlShakeComponent = %ControlShakeComponent
@onready var parry_icons: Array[TextureRect] = [%ParryIcon, %ParryIcon2, %ParryIcon3]
@onready var money_label: Label = %MoneyLabel
@onready var upgrade_icons_container: VBoxContainer = %UpgradeIconsContainer
@onready var upgrade_icons: Array[UpgradeIcon] = []
@onready var results_vbox: VBoxContainer = %ResultsVbox

# Run end controls
@onready var dead_text: Label = %DeadText
@onready var return_to_title_button: Button = %ReturnToTitleButton
@onready var upgrade_icons_gameover_container: HBoxContainer = %UpgradeIconsGameoverContainer
@onready var gameover_container: MarginContainer = $GameoverContainer
@onready var enemies_slain: Label = %EnemiesSlain
@onready var hits_taken: Label = %HitsTaken
@onready var parries_performed: Label = %ParriesPerformed
@onready var money_earned: Label = %MoneyEarned
@onready var items_bought: Label = %ItemsBought
@onready var jabberwocks_defeated: Label = %JabberwocksDefeated
@onready var levels_cleared: Label = %LevelsCleared

enum State {
	NONE,
	GAMEOVER,
	VICTORY
}

var player: Player = null
var state: State

func _ready() -> void:
	for icon in parry_icons:
		icon.visible = false
	
	return_to_title_button.pressed.connect(return_to_title_button_pressed)
	dead_text.visible = false
	results_vbox.visible = false
	
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
	player.player_died.connect(gameover)
	stamina_bar.max_value = current_player.max_stamina
	visible = true

func gameover(player: Player):
	gameplay_container.visible = false
	dead_text.modulate.a = 0.0
	dead_text.visible = true
	dead_text.pivot_offset = dead_text.size / 2
	results_vbox.modulate.a = 0.0
	results_vbox.visible = true
	
	enemies_slain.text = "ENEMIES SLAIN: " + str(RunStats.enemies_killed)
	money_earned.text = "MONEY EARNED: " + str(RunStats.money_earned)
	parries_performed.text = "PARRIES PERFORMED: " + str(RunStats.parries_performed)
	hits_taken.text = "HITS TAKEN: " + str(RunStats.hits_taken)
	items_bought.text = "ITEMS BOUGHT: " + str(RunStats.items_bought)
	jabberwocks_defeated.text = "JABBERWOCKS DEFEATED: " + str(RunStats.jabberwocks_defeated)
	levels_cleared.text = "LEVELS CLEARED: " + str(RunStats.levels_cleared)
	
	for child in upgrade_icons_gameover_container.get_children():
		child.queue_free()
	await get_tree().process_frame
	for child in upgrade_icons_container.get_children():
		upgrade_icons_gameover_container.add_child(child.duplicate())
	
	await get_tree().create_timer(2.5).timeout
	
	var tween: Tween
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(dead_text, "scale", Vector2.ONE, 2.0).from(Vector2(0.75, 0.75))
	tween.tween_property(dead_text, "modulate:a", 1.0, 2.0).from(0.0)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(dead_text, "scale", Vector2(1.25, 1.25), 2.0)
	tween.tween_property(dead_text, "modulate:a", 0.0, 1.0).from(1.0)
	await tween.finished
	await get_tree().create_timer(0.2).timeout
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(results_vbox, "modulate:a", 1.0, 1.0).from(0.0)

func return_to_title_button_pressed():
	return_to_title_button.disabled = true
	
	var tween: Tween
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(results_vbox, "modulate:a", 0.0, 1.0).from(1.0)
	await tween.finished
	Bgm.stop_bgm()
	get_tree().reload_current_scene()

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
