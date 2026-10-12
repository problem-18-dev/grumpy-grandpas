class_name SfxConfig
extends Node

enum PlayerSoundType {
	HELLO,
	START,
	SHOOT,
	DEATH,
	HURT,
}

static var player_sound_uids := {
	PlayerResource.Gender.GRANDPA: {
		PlayerSoundType.HELLO: ["uid://bhmbrhhrxhujl"],
		PlayerSoundType.START: ["uid://dpv362rwaysbs", "uid://bcwkyx1s6nyuu"],
		PlayerSoundType.SHOOT: ["uid://bp6t1d5h76piy", "uid://dbkh1x3dcs3bb"],
		PlayerSoundType.DEATH: ["uid://cc2c1yai0rxbv", "uid://jpadkv5nyvf2"],
		PlayerSoundType.HURT: ["uid://dbroxp0ye5kgd", "uid://dwwb3tb87k10y"],
	},
	PlayerResource.Gender.GRANDMA: {
		PlayerSoundType.HELLO: ["uid://cr7n43r30k3v5"],
		PlayerSoundType.START: ["uid://k2ooajxxy1sn", "uid://dq8fj8yw4g7dq"],
		PlayerSoundType.SHOOT: ["uid://rvjvlkc0i00t", "uid://cxf55dpr6l75r"],
		PlayerSoundType.DEATH: ["uid://camnudlsq17et", "uid://bikq5y1shjkdn"],
		PlayerSoundType.HURT: ["uid://bqps5e61e6j58", "uid://b44wj62y1j7ba"],
	},
}


static func get_player_sound(
	gender: PlayerResource.Gender,
	sound_type: PlayerSoundType,
) -> AudioStream:
	var sound: String = player_sound_uids[gender][sound_type].pick_random()
	return load(sound)
