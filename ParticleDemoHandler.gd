extends Node3D

@export var ParticleEffect : PackedScene
@export var SpawnSpread : float = 2.0

func _input(event):
	if (Input.is_action_just_pressed("Click")):
		var newParticle = ParticleEffect.instantiate() as Node3D
		add_child(newParticle)
		
		var rng : RandomNumberGenerator = RandomNumberGenerator.new()
		rng.randomize()
		
		newParticle.global_position = Vector3(rng.randf_range(-SpawnSpread, SpawnSpread), 0, rng.randf_range(-SpawnSpread, SpawnSpread))
