extends Node

func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(91162161207, 9999)
