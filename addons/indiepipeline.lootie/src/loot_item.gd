@tool
class_name LootItem extends Resource

## Expand here as to adjust it to your game requirements
enum ItemRarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, MYTHIC, ETERNAL, ABYSSAL, COSMIC, DIVINE} 

## Unique identifier for this item
@export var id: String = ""
## An optional file path that represents this item
@export_file var file
## An optional scene that represents this item
@export var scene: PackedScene
## The name of the item
@export var name : String
## A shortcut to display the name in short form for limit ui in screen
@export var abbreviation : String
## A description more detailed about this item
@export_multiline var description : String
## The weight value for this items to appear in a loot
@export var weight: float = 1.0
## The grade of rarity for this item
@export var grade: ItemRarity = ItemRarity.COMMON
## The minimum value in range to be available on the roll pick
@export var min_roll: float
## The maximum value in range to be available on the roll pick
@export var max_roll: float


var accum_weight: float = 0.0


func reset_accum_weight() -> void:
	accum_weight = 0.0


static func create_from(data: Dictionary = {}) -> LootItem:
	var item = LootItem.new()
	var valid_properties = item.get_property_list().map(func(property: Dictionary): return property.name)
	
	for property: String in data.keys():
		var property_name: String = property.to_snake_case()
		if valid_properties.has(property_name):
			item[property_name] = data[property]
			
	return item
