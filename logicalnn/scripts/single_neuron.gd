extends Node2D

enum {
	AF_SIGMOID = 0, AF_TANH, AF_RELU, AF_LEAKY_RELU,	# 活性化関数種別
	WI_1 = 0, WI_001, WI_XAVIER, WI_HE,					# 重み標準偏差・初期化方法
}
# ニューロンクラス、N入力１出力
# 活性化関数：シグモイド・tanh・ReLU etc ?
class Neuron:
	func _init(n_in, af, deviation:float):
		n_input = n_in
		actv_func = af
		# 重みベクター初期化
		vec_weight.resize(n_input+1)
		init_weight(deviation)		# 指定標準偏差で乱数生成
	func init_weight(deviation:float):
		if false:
			vec_weight[0] = 0.5
			vec_weight[1] = -0.5
			vec_weight[2] = 0.5
		elif true:
			# xavier 初期化
			for i in range(n_input+1):
				vec_weight[i] = randfn(0.0, 1.0/sqrt(n_input+1))
		else:
			# tsuda 初期化
			if n_input == 2:
				vec_weight[0] = sin(randf_range(0.0, 2*PI))
				var th = randf_range(0.0, 2*PI)
				vec_weight[1] = cos(th)
				vec_weight[2] = sin(th)
			else:
				vec_weight[0] = sin(randf_range(0.0, 2*PI))
				var sum2 = 0.0
				for i in range(1, n_input+1):
					vec_weight[i] = randfn(0.0, deviation)
					sum2 += vec_weight[i] * vec_weight[i]
				var sq = sqrt(sum2)
				for i in range(1, n_input+1):
					vec_weight[i] /= sq
	func sigmoid(x): return 1.0/(1.0 + exp(-x))
	func ReLU(x): return x if x > 0.0 else 0.0
	func LeakyReLU(x): return x if x > 0.0 else 0.01*x
	func forward(inp: Array):
		a = vec_weight[0]
		for i in range(n_input):
			a += vec_weight[i+1] * inp[i]
		if actv_func == AF_TANH: y = tanh(a)
		elif actv_func == AF_SIGMOID: y = sigmoid(a)
		elif actv_func == AF_RELU: y = ReLU(a)
		elif actv_func == AF_LEAKY_RELU: y = LeakyReLU(a)
		#print("a = ", a, ", y = ", y)
	func backward(inp: Array, grad: float):
		upgrad = []		# 上流勾配
		var dyda
		if actv_func == AF_TANH: dyda = (1.0 - y*y)			# tanh
		elif actv_func == AF_SIGMOID: dyda = y * (1.0 - y)	# sigmoid
		elif actv_func == AF_RELU: dyda = (0.0 if y <= 0 else 1.0)		# ReLU
			#if y <= 0: dyda = 0.0
			#else: dyda = 1.0
		elif actv_func == AF_LEAKY_RELU: dyda = (0.01 if y <= 0 else 1.0)		# Leaky ReLU
		var dydag = dyda * grad
		upgrad.push_back(dydag)		# for b
		#print("∂L/∂y = ", grad)
		#print("∂y/∂a = ", dyda)
		for i in range(n_input):	# for w1, w2, ...
			upgrad.push_back(dydag * inp[i])
	var n_input		# 入力データ数
	var actv_func	# 活性化関数種別
	var vec_weight = []		# [b, w1, w2, w3, ... wN] 重みベクター
	var a					# a = b + w1*x1 + w2*x2 + ... wN*xN
	var y					# y = af(a)
	var upgrad				# 上流勾配
#
enum {
	OP_AND = 0, OP_OR, OP_NAND, OP_NOR,
	OP_GT,		# x1 > x2
	OP_LT,		# x1 < x2
	OP_X1_GT_0, OP_X2_GT_0, 	# x1 > 0, X2 > 0
	OP_XOR, OP_NXOR,
	#
	LU_MINI_BATCH = 0, LU_ONLINE, LU_RANDOM_8,
}

const boolean_pos = [[0, 0], [1, 0], [0, 1], [1, 1]]
const boolean_pos_tanh = [[-1, -1], [1, -1], [-1, 1], [1, 1]]

var vec_weight_init			# 重み初期値
var n_iteration = 0			# 学習回数
var ope = OP_AND
var actv_func = AF_TANH
var false_0 = false			# false for false: -1.0
var ALPHA = 0.1				# 学習率
var norm = 0.1				# 重み初期化時標準偏差
var neuron
var grad

func teacher_value(inp:Array):
	if ope == OP_AND: return 1.0 if inp[0] != 0 && inp[1] != 0.0 else 0.0		# AND
	elif ope == OP_OR: return 1.0 if inp[0] != 0 || inp[1] != 0.0 else 0.0		# OR
	elif ope == OP_NAND: return 0.0 if inp[0] != 0 && inp[1] != 0.0 else 1.0	# NAND
	elif ope == OP_NOR: return 0.0 if inp[0] != 0 || inp[1] != 0.0 else 1.0		# NOR
	elif ope == OP_GT: return 1.0 if inp[0] > inp[1] else 0.0					# x1 > x2
	elif ope == OP_LT: return 1.0 if inp[0] < inp[1] else 0.0					# x1 > x2
	elif ope == OP_X1_GT_0: return 1.0 if inp[0] > 0 else 0.0					# x1 > 0
	elif ope == OP_X2_GT_0: return 1.0 if inp[1] > 0 else 0.0					# x2 > 0
	elif ope == OP_XOR: return 1.0 if inp[0] != inp[1] else 0.0					# XOR
	elif ope == OP_NXOR: return 0.0 if inp[0] != inp[1] else 1.0				# NXOR
	return 0.0
func teacher_value_ex(inp:Array):
	var t = teacher_value(inp)
	if actv_func != AF_SIGMOID && t == 0.0: t = -1.0
	#if !false_0 && t == 0.0: t = -1.0
	return t

func _ready():
	neuron = Neuron.new(2, AF_TANH, norm)
	vec_weight_init = neuron.vec_weight.duplicate()
	print(neuron.vec_weight)
	update_view()
	pass # Replace with function body.
func update_view():
	$ItrLabel.text = "Iteration: %d" % n_iteration
	$WeightLabel.text = "[b, w1, w2] = [%.3f, %.3f, %.3f]" % neuron.vec_weight
	$GraphRect.vv_weight = [neuron.vec_weight]
	$GraphRect.queue_redraw()
	forward_and_backward()
	##draw_loss_wt_graph()
func forward_and_backward():
	grad = [0.0, 0.0, 0.0]
	var sumLoss = 0.0
	var n_data = 0		# ミニバッチデータ数カウンタ
	for i in range(boolean_pos.size()):
		n_data += 1
		var t = teacher_value_ex(boolean_pos[i])	# 教師値
		var inp = boolean_pos[i] if false_0 else boolean_pos_tanh[i]
		neuron.forward(inp)
		var y = neuron.y
		if actv_func == AF_RELU:
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
	$GradLabel.text = "∂L/∂[b, w1, w2] = [%.3f, %.3f, %.3f]" % grad
	pass


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
	#do_train()
	pass # Replace with function body.


func _on_ope_button_item_selected(index):
	ope = index
	$GraphRect.ope = ope
	$GraphRect.queue_redraw()
	update_view()
	pass # Replace with function body.


func _on_rewind_button_pressed():
	n_iteration = 0
	neuron.vec_weight = vec_weight_init.duplicate()
	update_view()
	pass # Replace with function body.
