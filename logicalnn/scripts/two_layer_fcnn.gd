extends Node2D

var g = Global

var vec_weight_init1		# 重み初期値
var vec_weight_init2		# 重み初期値
var n_iteration = 0			# 学習回数
var ope = OP_AND
var actv_func = g.AF_TANH
var false_0 = false			# false for false: -1.0
var ALPHA = 0.1				# 学習率
var norm = 0.1				# 重み初期化時標準偏差
var neuron1
var neuron2
var grad

# Called when the node enters the scene tree for the first time.
func _ready():
	neuron1 = g.Neuron.new(2, g.AF_TANH, norm)
	neuron2 = g.Neuron.new(2, g.AF_TANH, norm)
	vec_weight_init1 = neuron1.vec_weight.duplicate()
	vec_weight_init2 = neuron2.vec_weight.duplicate()
	update_view()
	pass # Replace with function body.
func update_view():
	#$ItrLabel.text = "Iteration: %d" % n_iteration
	#$WeightLabel.text = "[b, w1, w2] = [%.3f, %.3f, %.3f]" % neuron.vec_weight
	$GraphRect1.vv_weight = [neuron1.vec_weight, neuron2.vec_weight]
	$GraphRect1.queue_redraw()
	#forward_and_backward()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
