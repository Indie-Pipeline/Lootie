@tool
class_name LootieTable extends Node

enum ProbabilityMode {
	Weight, ## The type of probability technique to apply on a loot, weight is the common case and generate random decimals while each time sum the weight of the next item
	RollTier ##  The roll tier uses a max roll number and define a number range for each tier.
}

## The available items that will be used on a roll for this loot table
@export var available_items: Array[LootItem] = []
@export var probability_type: ProbabilityMode = ProbabilityMode.Weight:
	set(value):
		probability_type = value
		notify_property_list_changed()
## When this is enabled items can be repeated for multiple rolls on this generation
@export var allow_duplicates: bool = false
## A little bias that is added to the total weight to increase the difficulty to drop more items
@export var extra_weight_bias: float = 0.0
## Max items that this loot table can generate on multiple rolls
@export var items_limit_per_loot: int = 3:
	set(value):
		items_limit_per_loot = value
		fixed_items_per_loot = min(fixed_items_per_loot, items_limit_per_loot)
## The minimum amount of items will be generated on each roll, it cannot be greater than items_limit_per_loot
@export var fixed_items_per_loot: int = 1:
	set(value):
		fixed_items_per_loot = min(value, items_limit_per_loot)
## Set to zero to not use it. This has priority over seed_string. Define a seed for this loot table. Doing so will give you deterministic results across runs
@export var seed_value: int = 0
## Set it to empty to not use it. Define a seed string that will be hashed to use for deterministic results
@export var seed_string: String = ""

var mirrored_items: Array[LootItem] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(items: Array[Variant] = []) -> void:
	if not items.is_empty():
		if typeof(items.front()) == TYPE_DICTIONARY:
			_create_from_dictionary(items)
		elif items.front() is LootItem:
			available_items.append_array(items)
	
	mirrored_items = available_items.duplicate()
	
	
func _ready() -> void:
	if mirrored_items.is_empty():
		mirrored_items = available_items.duplicate()
	
	_prepare_random_number_generator()

		
func roll(times: int = 10, except: Array[LootItem] = []) -> Array[LootItem]:
	var items_rolled: Array[LootItem] = []
	var max_picks: int = min(items_limit_per_loot, mirrored_items.size())
	times = max(1, times)
	
	for exception_items: LootItem in except:
		mirrored_items.erase(exception_items)
	
	if mirrored_items.size() > 0:
		
		match probability_type:
			ProbabilityMode.Weight:
				
				for i in range(times):
					items_rolled.append_array(roll_items_by_weight(mirrored_items))
					
					if items_rolled.size() >= max_picks:
						break
					
				if fixed_items_per_loot > 0:
					while items_rolled.size() < fixed_items_per_loot and not mirrored_items.is_empty():
						items_rolled.append_array(roll_items_by_weight(mirrored_items))
			
			ProbabilityMode.RollTier:
				pass
		
		## Reset the mirrored items after the multiple shuffles or erased items
	mirrored_items = available_items.duplicate()
		
	items_rolled.shuffle()
	
	return items_rolled.slice(0, max_picks)


func roll_items_by_weight(selected_items:  Array[LootItem] = mirrored_items) -> Array[LootItem]:
	var items_rolled: Array[LootItem] = []
	var total_weight: float = 0.0

	total_weight = _prepare_weight_on_items(mirrored_items)
	mirrored_items.shuffle()
	
	var roll_result: float = rng.randf_range(0, total_weight)
	
	for looted_item: LootItem in mirrored_items.filter(func(item: LootItem): return roll_result <= item.accum_weight):
		items_rolled.append(looted_item.duplicate())
			
		if not allow_duplicates:
			mirrored_items.erase(looted_item)

	return items_rolled
	
	
func _prepare_weight_on_items(target_items: Array[LootItem] = mirrored_items) -> float:
	var total_weight: float = 0.0
	
	for item: LootItem in target_items:
		item.reset_accum_weight()
		total_weight += item.weight
		item.accum_weight = total_weight
	
	return total_weight + extra_weight_bias


func change_probability_type(new_type: ProbabilityMode) -> void:
	probability_type = new_type


func add_items(items: Array[LootItem] = []) -> void:
	available_items.append_array(PluginUtilities.remove_duplicates(items))
	mirrored_items = available_items.duplicate()


func add_item(item: LootItem) -> void:
	available_items.append(item)
	available_items = PluginUtilities.remove_duplicates(available_items)
	mirrored_items = available_items.duplicate()
	

func remove_items(items: Array[LootItem] = []) -> void:
	available_items = available_items.filter(func(item: LootItem): return not item in items)
	mirrored_items = available_items.duplicate()
	

func remove_item(item: LootItem) -> void:
	available_items.erase(item)
	mirrored_items = available_items.duplicate()
	

func _create_from_dictionary(items: Array[Dictionary]= []) -> void:
	if not items.is_empty():
		for item: Dictionary in items:
			available_items.append(LootItem.create_from(item))

		
func _prepare_random_number_generator() -> void:
	if seed_value > 0:
		rng.seed = seed_value
	elif not seed_string.is_empty():
		rng.seed = seed_string.hash()
		
