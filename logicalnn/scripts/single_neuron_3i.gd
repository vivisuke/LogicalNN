extends Node2D

var g = Global

enum {
	OP_AND = 0, OP_OR, OP_NAND, OP_NOR,
	OP_GT,		# x1 > x2
	OP_LT,		# x1 < x2
	OP_X1_GT_0, OP_X2_GT_0, 	# x1 > 0, X2 > 0
	OP_XOR, OP_NXOR,
	#
	LU_MINI_BATCH = 0, LU_ONLINE, LU_RANDOM_8,
}

#const boolean_pos = [[0, 0, 0], [1, 0, 0], [0, 1, 0], [1, 1, 0],
#						[0, 0, 1], [1, 0, 1], [0, 1, 1], [1, 1, 1]]
const boolean_pos_tanh = [[-1, -1, -1], [1, -1, -1], [-1, 1, -1], [1, 1, -1],
							[-1, -1, 1], [1, -1, 1], [-1, 1, 1], [1, 1, 1]]

var vec_weight_init			# 重み初期値
var n_iteration = 0			# 学習回数
var ope = OP_AND
var actv_func = g.AF_TANH
var false_0 = false			# false for false: -1.0
var ALPHA = 0.01				# 学習率
var norm = 0.1				# 重み初期化時標準偏差
var neuron
var grad


#func teacher_value(inp:Array):
#	if ope == OP_AND: return 1.0 if inp[0] > 0 && inp[1] > 0.0 && inp[2] > 0.0 else 0.0		# AND
#	elif ope == OP_OR: return 1.0 if inp[0] != 0 || inp[1] != 0.0 || inp[2] != 0.0 else 0.0		# OR
#	#elif ope == OP_NAND: return 0.0 if inp[0] != 0 && inp[1] != 0.0 else 1.0	# NAND
#	#elif ope == OP_NOR: return 0.0 if inp[0] != 0 || inp[1] != 0.0 else 1.0		# NOR
#	#elif ope == OP_GT: return 1.0 if inp[0] > inp[1] else 0.0					# x1 > x2
#	#elif ope == OP_LT: return 1.0 if inp[0] < inp[1] else 0.0					# x1 > x2
#	#elif ope == OP_X1_GT_0: return 1.0 if inp[0] > 0 else 0.0					# x1 > 0
#	#elif ope == OP_X2_GT_0: return 1.0 if inp[1] > 0 else 0.0					# x2 > 0
#	#elif ope == OP_XOR: return 1.0 if inp[0] != inp[1] else 0.0					# XOR
#	#elif ope == OP_NXOR: return 0.0 if inp[0] != inp[1] else 1.0				# NXOR
#	return 0.0
func teacher_value_ex(inp:Array):
	var t = g.teacher_value_3i(ope, inp)
	#if actv_func != g.AF_SIGMOID && t == 0.0: t = -1.0
	#if !false_0 && t == 0.0: t = -1.0
	return t

func _ready():
	neuron = g.Neuron.new(3, g.AF_TANH, norm)		# ３入力単一ニューロン
	vec_weight_init = neuron.vec_weight.duplicate()
	print(neuron.vec_weight)
	update_view()
	pass
func update_view():
	$ItrLabel.text = "Iteration: %d" % n_iteration
	$WeightLabel.text = "[b, w1, w2, w3] = [%.3f, %.3f, %.3f, %.3f]" % neuron.vec_weight
	$GraphRect3i.weights = neuron.vec_weight
	$GraphRect3i.queue_redraw()
	forward_and_backward()
	pass
func forward_and_backward():
	grad = [0.0, 0.0, 0.0, 0.0]
	var sumLoss = 0.0
	var n_data = 0		# ミニバッチデータ数カウンタ
	for i in range(boolean_pos_tanh.size()):
		n_data += 1
		var t = teacher_value_ex(boolean_pos_tanh[i])	# 教師値
		var inp = boolean_pos_tanh[i]
		##var inp = boolean_pos[i] if false_0 else boolean_pos_tanh[i]
		neuron.forward(inp)
		var y = neuron.y
		if actv_func == g.AF_RELU:
			y = 1.0 if y > 0.0 else -1.0
		var d = y - t
		sumLoss += d * d / 2.0
		#
		#print(inp, " ", y, " ", t)
		neuron.backward(inp, d)
		for k in range(grad.size()):
			grad[k] += neuron.upgrad[k]
	var loss = sumLoss / n_data
	$LossLabel.text = "Loss = %.3f" % loss
	$GradLabel.text = "∂L/∂[b, w1, w2, w3] = [%.3f, %.3f, %.3f, %.3f]" % grad

func do_train():
	n_iteration += 1
	for i in range(neuron.vec_weight.size()):
		neuron.vec_weight[i] -= grad[i] * ALPHA
	update_view()

func _process(delta):
	if $HBC/TrainButton.button_pressed:
		do_train()
	pass


func _on_reset_button_pressed():
	n_iteration = 0
	neuron.init_weight(norm)
	vec_weight_init = neuron.vec_weight.duplicate()
	update_view()
	pass # Replace with function body.


func _on_train_button_pressed():
	pass # Replace with function body.


func _on_rewind_button_pressed():
	n_iteration = 0
	neuron.vec_weight = vec_weight_init.duplicate()
	update_view()
	pass # Replace with function body.


func _on_ope_button_item_selected(index):
	ope = index
	$GraphRect3i.ope = ope
	$GraphRect3i.queue_redraw()
	update_view()
	pass # Replace with function body.
