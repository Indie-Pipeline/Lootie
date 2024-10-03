@tool
class_name LootieTable extends Node

enum ProbabilityMode {
	Weight, ## The type of probability technique to apply on a loot, weight is the common case and generate random decimals while each time sum the weight of the next item
	RollTier ##  The roll tier uses a max roll number and define a number range for each tier.
}

## The available items that will be used on a roll for this loot table
@export var available_items: Array[LootItem] = []:
	set(value):
		available_items = value
		mirrored_items = available_items.duplicate()
		
@export var probability_type: ProbabilityMode = ProbabilityMode.Weight:
	set(value):
		probability_type = value
		notify_property_list_changed()
## When this is enabled items can be repeated for multiple rolls on this generation
@export var allow_duplicates: bool = true
## A little help that is added to the total weight to allow drop more items increasing the chance.
@export var extra_weight_bias: float = 0.0
## Max items that this loot table can generate
@export var items_limit_per_roll: int = 3
## At least the amount of items will be generated on each roll, it cannot be greater than items_limit_per_roll
@export var fixed_items_per_roll: int = 1:
	set(value):
		fixed_items_per_roll = min(value, items_limit_per_roll)


var mirrored_items: Array[LootItem] = []


func _init(items: Array[Variant] = []) -> void:
	if not items.is_empty():
		if typeof(items.front()) == TYPE_DICTIONARY:
			create_from_dictionary(items)
		elif items.front() is LootItem:
			available_items.append_array(items)
	
	mirrored_items = available_items.duplicate()
	
	
func create_from_dictionary(items: Array[Dictionary]= []) -> void:
	if not items.is_empty():
		for item: Dictionary in items:
			available_items.append(LootItem.create_from(item))


func change_probability_type(new_type: ProbabilityMode) -> void:
	probability_type = new_type
