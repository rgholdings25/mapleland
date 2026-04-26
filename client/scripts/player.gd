extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_force: float = -400.0
@export var gravity: float = 900.0
@export var attack_damage := 1
@export var attack_cooldown := 0.45
@export var attack_windup := 0.12
@export var attack_active_time := 0.12
@export var attack_range := 96.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_effect: Polygon2D = $AttackEffect

var can_attack := true
var facing_direction := 1.0
var hit_bodies: Array[Node] = []

func _ready() -> void:
	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_effect.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and can_attack:
		attack()

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var vertical_direction := Input.get_axis("move_up", "move_down")

	velocity.x = direction * speed

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	move_and_slide()

	if direction != 0:
		facing_direction = sign(direction)
		sprite.flip_h = direction < 0
		attack_area.position.x = facing_direction * attack_range
		attack_effect.position.x = facing_direction * attack_range
		attack_effect.scale.x = facing_direction

	if vertical_direction != 0:
		pass

func attack() -> void:
	can_attack = false
	hit_bodies.clear()

	var original_speed := speed
	speed = speed * 0.25
	print("Attack ready")

	await get_tree().create_timer(attack_windup).timeout
	speed = original_speed

	print("Attack")
	attack_effect.visible = true

	attack_area.monitoring = true
	await get_tree().physics_frame

	for body in attack_area.get_overlapping_bodies():
		_on_attack_area_body_entered(body)

	await get_tree().create_timer(attack_active_time).timeout
	attack_area.monitoring = false
	attack_effect.visible = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_attack_area_body_entered(body: Node) -> void:
	if hit_bodies.has(body):
		return

	if body.has_method("_on_hit"):
		hit_bodies.append(body)
		body._on_hit(attack_damage, facing_direction)
