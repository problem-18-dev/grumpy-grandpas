class_name HitscanWeaponResource
extends WeaponResource

const MINIMUM_RANGE := 75.0
const MAXIMUM_RANGE := 300.0

@export_group("Range")
@export_range(MINIMUM_RANGE, MAXIMUM_RANGE) var max_range := MAXIMUM_RANGE
