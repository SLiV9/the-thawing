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
