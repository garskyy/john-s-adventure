extends CharacterBody2D

const SPEED: float = 200.0
const JUMP_VELOCITY = -400.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") * 1.2
var is_facing_left: bool = false
@onready var sprite = %AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Физика
		# Гравитация
	if (not is_on_floor()):
		velocity.y += gravity * delta # падаем вниз по гравитации
		# Прыжок
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		# Управление
	velocity.x = Input.get_axis("move_left", "move_right") * SPEED # туда-сюда
	if (velocity.x != 0):
		is_facing_left = velocity.x < 0
	sprite.flip_h = is_facing_left
	move_and_slide()
	
	# Анимации
	if not is_on_floor():
		sprite.play("jump") # Прыжок
	elif velocity.x != 0:
		sprite.play("run") # Бег
	else:
		sprite.play("idle") # Стойка
