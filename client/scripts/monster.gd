extends CharacterBody2D

@export var max_health: int = 3
@export var gravity: float = 1200.0

@onready var body: Polygon2D = $Body

var health: int
var hit_flash_remaining := 0.0

func _ready() -> void:
	health = max_health

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if hit_flash_remaining > 0.0:
		hit_flash_remaining -= delta
		body.color = Color(1, 0.9, 0.2, 1)
	else:
		body.color = Color(0.9, 0.2, 0.25, 1)

	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	hit_flash_remaining = 0.12

	if health <= 0:
		queue_free()
