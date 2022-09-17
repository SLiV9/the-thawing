class_name FlagCounter
extends Reference

var data = {}


func push(flag):
	if data.has(flag):
		data[flag] += 1
	else:
		data[flag] = 1

func pop(flag):
	data[flag] -= 1

func count(flag):
	if data.has(flag):
		return data[flag]
	else:
		return 0

func count_difference(pos, neg):
	return count(pos) - count(neg)

func meets_conditions(conditions):
	if data.empty() and OS.has_feature("editor"):
		# We are doing a pre-load check of the entire dialogue tree.
		return true
	for condition in conditions:
		if condition.begins_with("!"):
			var flag = condition.trim_prefix("!")
			if self.count(flag) > 0:
				return false
		else:
			var flag = condition
			if self.count(flag) <= 0:
				return false
	return true

func get_save_data():
	return self.data

func load_from_data(d):
	self.data = d
