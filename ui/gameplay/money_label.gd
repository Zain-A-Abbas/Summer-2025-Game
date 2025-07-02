extends Label
class_name MoneyLabel

var money_tween: Tween
var money_indicator_amount: int = 0

func _process(delta: float) -> void:
	set_text(str(money_indicator_amount))

func update_money_indicator(new_money: int):
	money_tween = create_tween()
	money_tween.tween_property(self, "money_indicator_amount", new_money, new_money * 0.5 * 0.01)
