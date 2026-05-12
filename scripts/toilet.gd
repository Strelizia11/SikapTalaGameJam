extends Control

@onready var transition_player = $Transition/Transitions/AnimationPlayer
@onready var overlay = $Transition/Transitions/ColorRect

func _ready():
	$door.pressed.connect(_on_door_pressed)

	# 1. Group item variants by their item_name
	var item_groups = {}

	for node in get_children():
		if node.has_method("add_to_group"):
			node.add_to_group("items")

		if "item_name" in node and node.item_name != "":
			var i_name = node.item_name
			if not item_groups.has(i_name):
				item_groups[i_name] = []
			item_groups[i_name].append(node)

	# 2. Retrieve our saved variants from the InventoryManager 
	# (or create a new empty dictionary if it's the player's first time entering)
	var saved_variants = {}
	if InventoryManager.has_meta("toilet_item_variants"):
		saved_variants = InventoryManager.get_meta("toilet_item_variants")
	else:
		InventoryManager.set_meta("toilet_item_variants", saved_variants)

	# 3. Iterate through each group and check our saved data
	for i_name in item_groups.keys():
		var variants = item_groups[i_name]
		var chosen_variant = null
		
		# Check if we ALREADY chose a variant for this item in this playthrough
		if saved_variants.has(i_name):
			var saved_node_name = saved_variants[i_name]
			for variant in variants:
				if variant.name == saved_node_name:
					chosen_variant = variant
					break
		
		# If we haven't chosen one yet (first time entering the room!), pick one and SAVE its name
		if chosen_variant == null:
			chosen_variant = variants.pick_random()
			saved_variants[i_name] = chosen_variant.name
		
		# Now, keep the chosen one and delete the rest
		for variant in variants:
			if variant == chosen_variant:
				# Permanently submitted to a prompt — destroy it forever
				if InventoryManager.is_permanently_removed(i_name):
					variant.queue_free()
				# Already in inventory (picked up but not submitted yet) — hide it
				elif InventoryManager.is_picked_up(i_name, "toilet"):
					variant.queue_free()
				# Otherwise leave it visible
			else:
				# Not the chosen variant for this playthrough — remove it
				variant.queue_free()
			
	transition_player.play("black_to_fade")
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	await transition_player.animation_finished
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Inventory.current_room = "toilet"

func _on_door_pressed():
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	transition_player.play("fade_to_black")
	await transition_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/corridor.tscn")
