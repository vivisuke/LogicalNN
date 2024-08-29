extends Node2D

var g = Global

var vec_weight_init			# 重み初期値
var n_iteration = 0			# 学習回数
var ope = OP_AND
var actv_func = g.AF_TANH
var false_0 = false			# false for false: -1.0
var ALPHA = 0.1				# 学習率
var norm = 0.1				# 重み初期化時標準偏差
var neuron
var grad


# Called when the node enters the scene tree for the first time.
func _ready():
	neuron = g.Neuron.new(3, g.AF_TANH, norm)		# ３入力単一ニューロン
	vec_weight_init = neuron.vec_weight.duplicate()
	print(neuron.vec_weight)
	update_view()
	pass
func update_view():
	$GraphRect3i.weights = neuron.vec_weight
	$GraphRect3i.queue_redraw()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
