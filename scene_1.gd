extends Node2D
var stay_or_not =-1
var speed = 300
var overridespeed = 400
var overridden=-1
var state = -1
var direction = Vector2(1,0)
var screen_size=Vector2()
var window_size=Vector2(200, 200)
var idle_timer = 0.0
var is_idling= false
func stay():
	#print("stay oh")
	DisplayServer.window_set_position(Vector2(-1,1))
func override(delta):
	#print("override oh")
	var window_position=Vector2(DisplayServer.window_get_position())
	var pet = window_position+Vector2(100,100)
	var to_mouse = Vector2(DisplayServer.mouse_get_position()) - pet
	if to_mouse.length() < 5.0:
		return
	var master = to_mouse.normalized()
	window_position += master * overridespeed * delta
	DisplayServer.window_set_position(Vector2i(window_position))
func maybe_idle():
	if randf() < 0.7:
		is_idling = true
		idle_timer = randf_range(1.0,10.0)
		var r = randi() %3
		if r==0:
			animated_sprite.play("Idle")
			speed = 0
@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D
var is_dragging = false
var drag_offset = Vector2()
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
		else:
			is_dragging = false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			$PopupMenu. popup_on_parent(Rect2i(Vector2i(event.position), Vector2i.ZERO))
			$PopupMenu.id_pressed.connect(_on_menu_pressed)
	if event is InputEventMouseButton and event.pressed and event.double_click:
		#print("double click!")
		state=-1*state
		if state==1:
			speed=0
			animated_sprite.play("Idle")
		else:
			speed=500
			animated_sprite.play("Walk_Right")
func _ready():
	#print("Inside Ready")
	screen_size = Vector2(DisplayServer.screen_get_size())
	animated_sprite.play("Walk_Right")
	area.input_event.connect(_on_input_event)
	$PopupMenu.add_item("Override", 1)
	$PopupMenu.add_item("Stay", 0)
func _physics_process(delta: float) -> void:
	if is_dragging:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos-drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		return
	if overridden == 1:
		override(delta)
		return
	if is_idling:
		idle_timer -= delta
		if idle_timer<=0:
			is_idling = false
			speed=300
			animated_sprite.play("Walk_Right")
		return
	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction * speed * delta
	#print(window_position)
	window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y, 0, screen_size.y - window_size.y)
	DisplayServer.window_set_position(Vector2i(window_position))
	if window_position.x<=0 or window_position.x>=screen_size.x-window_size.x:
		direction.x *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
		maybe_idle()
	if window_position.y<=0 or window_position.y>=screen_size.y-window_size.y:
		direction.y*=-1
		maybe_idle()
	if stay_or_not==1:
		stay()
func _on_menu_pressed(id):
	#print("menu_works")
	if id == 0:
		#print("staying")
		stay_or_not=-1*stay_or_not
	if id == 1:
		#print("override")
		overridden=-1*overridden
