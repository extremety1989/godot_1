extends Node

func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client("91.162.161.207", 9999)
	get_tree().network_peer = peer
	var selfPeerID = get_tree().get_network_unique_id()
	print(selfPeerID)
