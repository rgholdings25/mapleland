extends CharacterBody2D

@export var move_speed: float = 220.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1200.0
@export var attack_damage: int = 1
@export var attack_cooldown: float = 0.35

@onready var attack_area: Area2D = $AttackArea
@onready var attack_preview: Polygon2D = $AttackArea/AttackPreview

var facing_direction := 1.0
var attack_cooldown_remaining := 0.0
var attack_preview_remaining := 0.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")

	velocity.x = direction * move_speed
	if direction != 0.0:
		facing_direction = sign(direction)

	attack_area.position.x = facing_direction * 44.0

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if attack_cooldown_remaining > 0.0:
		attack_cooldown_remaining -= delta

	if attack_preview_remaining > 0.0:
		attack_preview_remaining -= delta
		attack_preview.visible = true
	else:
		attack_preview.visible = false

	if Input.is_action_just_pressed("attack") and attack_cooldown_remaining <= 0.0:
		attack()

	move_and_slide()

func attack() -> void:
	attack_cooldown_remaining = attack_cooldown
	attack_preview_remaining = 0.1

	for body in attack_area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)
