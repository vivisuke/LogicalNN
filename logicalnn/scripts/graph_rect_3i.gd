extends ColorRect

var SZ = self.size
var SCREEN_WD = SZ.x
var SCREEN_HT = SZ.y
const SPACE_TOP = 30.0
const SPACE_BOTTOM = 30.0
const SPACE_LEFT = 40.0
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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
	draw_line(Vector2(LT, ORG_Y-GRAPH_HT/4), Vector2(RT, ORG_Y+GRAPH_HT/4), Color.GRAY)		# x1 軸
	draw_line(Vector2(LT, ORG_Y+GRAPH_HT/4), Vector2(RT, ORG_Y-GRAPH_HT/4), Color.GRAY)		# x2 軸
	draw_line(Vector2(ORG_X, TOP), Vector2(ORG_X, BTM), Color.GRAY)		# x3軸
