extends Node


## A set of global loot tables that need to be globally accessible in order to be re-used
var loot_tables: Dictionary = {}


func add_loot_table(id: String, loot_table: LootieTable) -> void:
	loot_tables[id] = loot_table
