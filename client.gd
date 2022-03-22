extends Spatial


const PORT = 4444
const ADDR = "35.186.245.55"
var dtls = true
var secure = PacketPeerDTLS.new()
var udp = PacketPeerUDP.new()

func _log(msg):
	print(msg)

func _process(delta):
	if not udp.is_connected_to_host():
		return
	var conn = udp
	if dtls:
		conn = secure
		conn.poll()
		if conn.get_status() != PacketPeerDTLS.STATUS_CONNECTED:
			return
		if conn.get_status() == PacketPeerDTLS.STATUS_CONNECTED:
			print("connected")
		secure.put_packet(var2bytes({"code":1,"username":"tester","P":Vector3(0,1,2)},true))
	while conn.get_available_packet_count() > 0:
		var pkt = conn.get_packet()
		var values = bytes2var(pkt,true)
		print(values)


func _ready():
	_log("Connect to %s %d: %d" % [ADDR, PORT, udp.connect_to_host(ADDR, PORT)])
	if dtls:
		secure.connect_to_peer(udp, false, "game", load("res://x509_certificate.crt"))
