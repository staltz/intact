extends Node2D

const RedDot = preload("res://RedDot.tscn")

const LOWEST_PITCH = 42
var active_dots = {}

func pitch_to_tiles(pitch):
	var tiles = []
	for row in range(8):
		var col = pitch - LOWEST_PITCH - (7 - row)*5
		if 0 <= col && col <= 15:
			tiles.append(Vector2(row, col))
	return tiles
	
func tile_to_position(tile):
	# x=75 (50 tile size + 25 half tile size) is the center of the top-left tile
	return Vector2(75 + tile[1]*50, 75 + tile[0]*50)

func _ready():
	OS.open_midi_inputs()

func pitch_to_note(pitch):
	return ['C', 'c', 'D', 'd', 'E', 'F', 'f', 'G', 'g', 'A', 'a', 'B'][pitch % 12]

func relative_note(rootpitch, pitch):
	return ['(2)', '2', '(3)', '3', '4', '(5)', '5', '(6)', '6', '(7)', '7', '8'][(pitch - rootpitch - 1) % 12]

func pitches_to_chord(pitches):
	if pitches.size() == 0: return ''
	pitches.sort()
	var rootpitch = pitches.pop_front()
	var chord = pitch_to_note(rootpitch)
	var hashat = false
	for pitch in pitches:
		if pitch - rootpitch > 12 and !hashat:
			hashat = true
			chord = chord + '^'
		chord = chord + relative_note(rootpitch, pitch)
	return chord

func calculate_relative(root, pitch):
	return ['(2)', '2', '(3)', '3', '4', '(5)', '5', '(6)', '6', '(7)', '7']

func _input(event):
	if event is InputEventMIDI:
		#print(event.pitch)
		var tiles = pitch_to_tiles(event.pitch)
		if event.message == 9: # key down
			active_dots[event.pitch] = []
			for tile in tiles:
				var dot = RedDot.instance()
				dot.position = tile_to_position(tile)
				active_dots[event.pitch].append(dot)
				$DotsContainer.add_child(dot)
		if event.message == 8: # key up
			var dots = active_dots[event.pitch]
			for dot in dots:
				active_dots.erase(event.pitch)
				$DotsContainer.remove_child(dot)
		$ChordLabel.text = pitches_to_chord(active_dots.keys())
