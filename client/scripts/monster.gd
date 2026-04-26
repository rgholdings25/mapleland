extends CharacterBody2D

var hp := 3
var hit_flash_time := 0.0
var knockback_velocity := 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
	if hit_flash_time > 0.0:
		hit_flash_time -= delta
		sprite.modulate = Color(1, 1, 1, 1)
	else:
		sprite.modulate = Color(1, 0.5, 0.5, 1)

	velocity.x = knockback_velocity
	knockback_velocity = move_toward(knockback_velocity, 0.0, 900.0 * delta)
	move_and_slide()

func _on_hit(damage := 1, hit_direction := 1.0) -> void:
	hp -= damage
	hit_flash_time = 0.12
	knockback_velocity = hit_direction * 220.0
	print("Monster hit. HP:", hp)

	if hp <= 0:
		queue_free()
