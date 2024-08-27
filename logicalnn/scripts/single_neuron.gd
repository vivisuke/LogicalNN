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
			for i in range(n_input+1):
				vec_weight[i] = randfn(0.0, deviation)
		else:
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
	OP_AND = 0, OP_OR, OP_NAND,
	OP_GT,		# x1 > x2
	OP_XOR,
	#
	LU_MINI_BATCH = 0, LU_ONLINE, LU_RANDOM_8,
}

var vec_weight_init			# 重み初期値
var n_iteration = 0			# 学習回数
var ope = OP_AND
var actv_func = AF_SIGMOID
var false_0 = true			# false for false: -1.0
var ALPHA = 0.1				# 学習率
var norm = 0.1				# 重み初期化時標準偏差
var neuron
var grad

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
	##forward_and_backward()
	##draw_loss_wt_graph()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
