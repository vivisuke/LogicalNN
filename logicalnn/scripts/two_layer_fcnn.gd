extends Node2D

var g = Global

const boolean_pos_tanh = [[-1, -1], [1, -1], [-1, 1], [1, 1]]


var vec_weight_init11		# 重み初期値
var vec_weight_init12		# 重み初期値
var vec_weight_init21		# 重み初期値
var n_iteration = 0			# 学習回数
var ope = OP_AND
var actv_func = g.AF_TANH
var false_0 = false			# false for false: -1.0
var ALPHA = 0.1				# 学習率
var norm = 0.1				# 重み初期化時標準偏差
var neuron11				# for 1st Layer
var neuron12
var neuron21				# for 2nd Layer
var grad

# Called when the node enters the scene tree for the first time.
func _ready():
	neuron11 = g.Neuron.new(2, g.AF_TANH, norm)
	neuron12 = g.Neuron.new(2, g.AF_TANH, norm)
	neuron21 = g.Neuron.new(2, g.AF_TANH, norm)
	vec_weight_init11 = neuron11.vec_weight.duplicate()
	vec_weight_init12 = neuron12.vec_weight.duplicate()
	vec_weight_init21 = neuron21.vec_weight.duplicate()
	update_view()
	pass # Replace with function body.
func update_view():
	$ItrLabel.text = "Iteration: %d" % n_iteration
	forward_and_backward()
	#$WeightLabel.text = "[b, w1, w2] = [%.3f, %.3f, %.3f]" % neuron.vec_weight
	$GraphRect1.vv_weight = [neuron11.vec_weight, neuron12.vec_weight]
	$GraphRect2.vv_weight = [neuron21.vec_weight]
	$GraphRect1.queue_redraw()
	$GraphRect2.queue_redraw()
func forward_and_backward():
	print("func forward_and_backward():")
	var vec_input = []				# 2nd Layer入力データ配列,  [x1, y1, bool]
	grad = [0.0, 0.0, 0.0, 0.0]
	var sumLoss = 0.0
	var n_data = 0		# ミニバッチデータ数カウンタ
	for i in range(boolean_pos_tanh.size()):
		n_data += 1
		#var t = teacher_value_ex(boolean_pos_tanh[i])	# 教師値
		var inp = boolean_pos_tanh[i]
		##var inp = boolean_pos[i] if false_0 else boolean_pos_tanh[i]
		neuron11.forward(inp)
		neuron12.forward(inp)
		var y1 = neuron11.y
		var y2 = neuron12.y
		print("%f, %f"%[y1, y2])
		vec_input.push_back([y1, y2, 1])
		#if actv_func == g.AF_RELU:
		#	y = 1.0 if y > 0.0 else -1.0
		#var d = y - t
		#sumLoss += d * d / 2.0
		#
		#print(inp, " ", y, " ", t)
		#neuron.backward(inp, d)
		#for k in range(grad.size()):
		#	grad[k] += neuron.upgrad[k]
	$GraphRect2.vec_input = vec_input.duplicate()
	#var loss = sumLoss / n_data
	#$LossLabel.text = "Loss = %.3f" % loss
	#$GradLabel.text = "∂L/∂[b, w1, w2, w3] = [%.3f, %.3f, %.3f, %.3f]" % grad
	#--update_view()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_reset_button_pressed():
	n_iteration = 0
	neuron11.init_weight(norm)
	neuron12.init_weight(norm)
	vec_weight_init11 = neuron11.vec_weight.duplicate()
	vec_weight_init12 = neuron12.vec_weight.duplicate()
	vec_weight_init21 = neuron21.vec_weight.duplicate()
	update_view()
	pass # Replace with function body.
