shader_type spatial;
render_mode cull_disabled, depth_prepass_alpha;

uniform sampler2D GradientFalloff;
uniform sampler3D NoiseTexture;
uniform float NoiseTexturePower : hint_range(0,1.0) = 0.5;
uniform float NoiseTextureSoftness : hint_range(0,0.5) = 0.2;
uniform vec3 ColorTint : source_color;
uniform float AlphaCutoff : hint_range(0,1) = 0.5;
uniform float TimeScale;
uniform float NoiseScale;
uniform float EmissionPower;
uniform float EmissionAlphaPower;
uniform float DisplacementScale;

varying vec3 world_position;


void vertex(){
	vec3 vertex_adjusted = VERTEX;
	
	vertex_adjusted = (MODEL_MATRIX * vec4(vertex_adjusted, 0.0)).xyz;
	vertex_adjusted.y += TIME * TimeScale;
	world_position = (NODE_POSITION_WORLD.xyz + vertex_adjusted) * NoiseScale;
	
	float displacement = texture(NoiseTexture, world_position).r * DisplacementScale;
	VERTEX += NORMAL * (displacement - (DisplacementScale / 2.0));
}

void fragment() {	
	//ALBEDO = texture(GradientFalloff, UV).rgb;
	vec3 noise_texture = texture(NoiseTexture, world_position).rgb;
	
	float TextureAlpha = smoothstep(NoiseTextureSoftness,1.0 - NoiseTextureSoftness, pow(NoiseTexturePower, noise_texture.r));
	
	ALBEDO = mix(ColorTint, COLOR.rgb, TextureAlpha);
	BACKLIGHT = vec3(1.0);
	ALPHA = COLOR.a * (noise_texture.r + 0.5) * texture(GradientFalloff, UV).r;
	EMISSION = COLOR.rgb * ((EmissionPower * noise_texture.r) * pow(texture(GradientFalloff, UV).r, EmissionAlphaPower) * COLOR.a);
	ALPHA_SCISSOR_THRESHOLD = AlphaCutoff;
}

