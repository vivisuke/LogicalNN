extends ColorRect

var g = Global

var SZ = self.size
var SCREEN_WD = SZ.x
var SCREEN_HT = SZ.y
const SPACE_TOP = 30.0
const SPACE_BOTTOM = 30.0
const SPACE_LEFT = 40.0
const TRUE_COL = Color.RED
const FALSE_COL = Color.BLUE
var GRAPH_HT = SCREEN_HT - (SPACE_TOP + SPACE_BOTTOM)
var GRAPH_WD = GRAPH_HT
const SCALE_WD = 6				# 目盛り幅
const LLT = 8
const LT = SPACE_LEFT
var RT = SPACE_LEFT + GRAPH_WD
const TOP = SPACE_TOP
var BTM = SPACE_TOP + GRAPH_HT
const BTM_OFST = 12
const LT_OFST = 12
var ORG_X = SPACE_LEFT + GRAPH_WD/2
var ORG_Y = SPACE_TOP + GRAPH_HT/2
const DOT_RADIUS = 4.0
const PLANE_DOT_RADIUS = 2.0
#var angle_3d = 0.0			# 0°
var angle_3d = PI/6.0		# 30°
#var angle_3d = PI/4.0		# 45°
var angle30 = PI / 6.0
var scale_3d2d = 75.0
var x1_label
var x2_label
var x3_label
var div_cross = [0, 0, 0]			# 分割面法線方向ベクター
var ope = g.OP_AND
var weights = [-1.0, 0.5, 0.5, 1.0]			# [b, w1, w2, w3] 重みベクター

func trans_3d_2d(x1:float, x2:float, x3:float) -> Vector2:
	if true:
		var x = -cos(angle_3d) * x1
		var y = sin(angle_3d) * x1
		var angle2 = angle_3d + PI/2.0
		x -= x2 * cos(angle2)
		y += x2 * sin(angle2)
		y /= 2
		y -= x3
		return Vector2(x*scale_3d2d+ORG_X, y*scale_3d2d+ORG_Y)
	else:
		var cos30 = cos(angle30)
		var sin30 = sin(angle30)
		var x = 0
		var y = 0
		x -= x1 * cos30
		y += x1 * sin30
		x += x2 * cos30
		y += x2 * sin30
		y -= x3
		##return Vector2(x, y)
		return Vector2(x*scale_3d2d+ORG_X, y*scale_3d2d+ORG_Y)

# 目盛り値ラベル設置
func add_axis_label(pos, txt):
	var lbl = Label.new()
	lbl.add_theme_color_override("font_color", Color.BLACK)
	lbl.text = txt
	lbl.position = pos
	add_child(lbl)
	return lbl

func _ready():
	# "x1", "x2", "x3" 表示
	x1_label = add_axis_label(Vector2(LT+BTM_OFST, ORG_Y+GRAPH_HT/4), "x1")
	x2_label = add_axis_label(Vector2(RT-BTM_OFST*2, ORG_Y+GRAPH_HT/4), "x2")
	x3_label = add_axis_label(Vector2(ORG_X+3, TOP), "x3")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	angle_3d += PI/720		# 1/4°
	#angle_3d += PI/360		# 1/2°
	#angle_3d += PI/180		# 1°
	if angle_3d >= 2*PI: angle_3d -= 2*PI
	queue_redraw()
	pass

func plot_boolean_sub(x1, x2, x3):
	var b = g.teacher_value_3i(ope, [x1, x2, x3])
	var pos = trans_3d_2d(x1, x2, x3);
	draw_circle(pos, DOT_RADIUS*1.5, TRUE_COL if b > 0 else FALSE_COL)
	draw_arc(pos, DOT_RADIUS*1.5, 0.0, 2*PI, 128, Color.BLACK, 0.5, true)
func plot_boolean():
	plot_boolean_sub(-1, -1, -1)
	plot_boolean_sub( 1, -1, -1)
	plot_boolean_sub(-1,  1, -1)
	plot_boolean_sub( 1,  1, -1)
	plot_boolean_sub(-1, -1,  1)
	plot_boolean_sub( 1, -1,  1)
	plot_boolean_sub(-1,  1,  1)
	plot_boolean_sub( 1,  1,  1)
func _draw():
	#print("draw()")
	# 背景＋影 描画
	var style_box = StyleBoxFlat.new()      # 影、ボーダなどを描画するための矩形スタイルオブジェクト
	style_box.bg_color = Color.WHITE   		# 矩形背景色
	style_box.shadow_offset = Vector2(0, 4)     # 影オフセット
	style_box.shadow_size = 8                   # 影（ぼかし）サイズ
	style_box.shadow_color = Color.GRAY
	draw_style_box(style_box, Rect2(Vector2(0, 0), self.size))      # style_box に設定した矩形を描画
	# 座標軸描画
	draw_line(trans_3d_2d(3, 0, 0), trans_3d_2d(-3, 0, 0), Color.GRAY)		# x1 軸
	draw_line(trans_3d_2d(0, 3, 0), trans_3d_2d(0, -3, 0), Color.GRAY)		# x2 軸
	draw_line(trans_3d_2d(0, 0, 3), trans_3d_2d(0, 0, -3), Color.GRAY)		# x3 軸
	# 座標軸上の整数点に黒丸描画
	for x in range(-2, 3):
		draw_circle(trans_3d_2d(x, 0, 0), DOT_RADIUS/2, Color.BLACK)
		draw_circle(trans_3d_2d(0, x, 0), DOT_RADIUS/2, Color.BLACK)
		draw_circle(trans_3d_2d(0, 0, x), DOT_RADIUS/2, Color.BLACK)
	#
	#draw_circle(trans_3d_2d(0, 0, 0), DOT_RADIUS, Color.BLACK)		# 原点
	#draw_circle(trans_3d_2d(2, 0, 0), DOT_RADIUS, Color.BLACK)		# x1 = 2.0
	#draw_circle(trans_3d_2d(0, 2, 0), DOT_RADIUS, Color.BLACK)		# x2 = 2.0
	#draw_circle(trans_3d_2d(0, 0, 2), DOT_RADIUS, Color.BLACK)
	#
	draw_div_plane()		# 分割面描画
	#if true:
	#	# 4x4x4 立方体頂点
	#	draw_circle(trans_3d_2d( 2,  2,  2), DOT_RADIUS, Color.BLACK)
	#	draw_circle(trans_3d_2d(-2,  2,  2), DOT_RADIUS, Color.BLACK)
	#	draw_circle(trans_3d_2d( 2, -2,  2), DOT_RADIUS, Color.BLACK)
	#	draw_circle(trans_3d_2d(-2, -2,  2), DOT_RADIUS, Color.BLACK)
	#	draw_circle(trans_3d_2d( 2,  2, -2), DOT_RADIUS, Color.BLACK)
	#	draw_circle(trans_3d_2d(-2,  2, -2), DOT_RADIUS, Color.BLACK)
	#	draw_circle(trans_3d_2d( 2, -2, -2), DOT_RADIUS, Color.BLACK)
	#	draw_circle(trans_3d_2d(-2, -2, -2), DOT_RADIUS, Color.BLACK)
	if true:
		# 4x4x4 立方体エッジ
		draw_dashed_line(trans_3d_2d( 2,  2,  2), trans_3d_2d( -2,  2,  2), Color.BLACK, 2.0)
		draw_dashed_line(trans_3d_2d(-2,  2,  2), trans_3d_2d( -2, -2,  2), Color.BLACK, 2.0)
		draw_dashed_line(trans_3d_2d(-2, -2,  2), trans_3d_2d(  2, -2,  2), Color.BLACK, 2.0)
		draw_dashed_line(trans_3d_2d( 2, -2,  2), trans_3d_2d(  2,  2,  2), Color.BLACK, 2.0)
		draw_dashed_line(trans_3d_2d( 2,  2, -2), trans_3d_2d( -2,  2, -2), Color.BLACK, 2.0)
		draw_dashed_line(trans_3d_2d(-2,  2, -2), trans_3d_2d( -2, -2, -2), Color.BLACK, 2.0)
		draw_dashed_line(trans_3d_2d(-2, -2, -2), trans_3d_2d(  2, -2, -2), Color.BLACK, 2.0)
		draw_dashed_line(trans_3d_2d( 2, -2, -2), trans_3d_2d(  2,  2, -2), Color.BLACK, 2.0)
		draw_dashed_line(trans_3d_2d( 2,  2,  2), trans_3d_2d(  2,  2, -2), Color.BLACK, 2.0)
		draw_dashed_line(trans_3d_2d(-2,  2,  2), trans_3d_2d( -2,  2, -2), Color.BLACK, 2.0)
		draw_dashed_line(trans_3d_2d(-2, -2,  2), trans_3d_2d( -2, -2, -2), Color.BLACK, 2.0)
		draw_dashed_line(trans_3d_2d( 2, -2,  2), trans_3d_2d(  2, -2, -2), Color.BLACK, 2.0)
	# x1, x2 ラベル
		x1_label.position = trans_3d_2d(2.5, 0, 0)
		x2_label.position = trans_3d_2d(0, 2.5, 0)
	# 教師値頂点ドット表示
	plot_boolean()

func draw_div_plane():# 分割面描画
	var angle = [cos(angle_3d), sin(angle_3d), 0.0]
	var dot = div_cross[0]*angle[0] + div_cross[1]*angle[1]
	#print("dot = %.3f"%dot)
	var col = Color.DARK_GREEN if dot >= 0.0 else Color.PINK
	for x30 in range(-20, 20, 2):
		var x3 = x30 / 10.0
		for x20 in range(-20, 20, 2):
			var x2 = x20 / 10.0
			var x1 = -(weights[0] + x2*weights[2] + x3*weights[3]) / weights[1];
			#print(x1, x2, x3)
			if x1 >= -2.0 && x1 <= 2.0 && x2 >= -2.0 && x2 <= 2.0 && x3 >= -2.0 && x3 <= 2.0:
				draw_circle(trans_3d_2d( x1,  x2,  x3), PLANE_DOT_RADIUS, col)
			
