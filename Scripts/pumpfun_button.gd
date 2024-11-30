extends Button


const pumpfun_link = "https://pump.fun/coin/EuJftPd3UfDd2kPgmDqMKoAazkaGsw8rzvM5NTXzpump"
# Called when the node enters the scene tree for the first time.

func _pressed() -> void:
	OS.shell_open(pumpfun_link)
