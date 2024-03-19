// Modified version of this shader: https://godotshaders.com/shader/distortion-bubble/
// Credits for original shader go to original creator.

shader_type spatial;

render_mode unshaded, cull_disabled;

// fragment uniforms
uniform float distortionView : hint_range(0.0, 0.3, 0.005) = 0.03;
uniform sampler2D screenTexture : hint_screen_texture;
uniform sampler2D depthTexture : hint_depth_texture;
uniform vec3 tintColor : source_color;
uniform float fesnelAmount : hint_range(0.0, 5.0, 0.1);
uniform float fesnelViewEffectAmount : hint_range(0.0, 1.0) = 0.5;


// vertex uniforms
uniform float DisplacementScale : hint_range(0.0, 0.3, 0.005) = 0.03;
uniform float speedVertex : hint_range(0.0, 1.0, 0.005) = 0.1;

uniform float NoiseScale;
uniform sampler3D NoiseTexture;

varying vec3 world_position;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void vertex()
{
	vec3 vertex_adjusted = VERTEX;
	
	vertex_adjusted = (MODEL_MATRIX * vec4(vertex_adjusted, 0.0)).xyz;
	vertex_adjusted.y += TIME * speedVertex;
	world_position = (NODE_POSITION_WORLD.xyz + vertex_adjusted) * NoiseScale;
	
	float displacement = texture(NoiseTexture, world_position).r * DisplacementScale;
	VERTEX += NORMAL * (displacement - (DisplacementScale / 2.0));

}

void fragment() 
{
	float fresnelPower = fresnel(fesnelAmount, NORMAL, VIEW);
	float noise_texture_A = texture(NoiseTexture, world_position).r;
	float noise_texture_B = texture(NoiseTexture, world_position + vec3(100,100,100)).r;
	vec2 noiseDistort = vec2(noise_texture_A, noise_texture_B) * (distortionView + (fresnelPower * fesnelViewEffectAmount));
	vec3 distortedScreenTexture = vec3(texture(screenTexture, SCREEN_UV + noiseDistort).rgb);
	vec3 fesnelTint = (tintColor * fresnelPower);
	
	ALBEDO = distortedScreenTexture + fesnelTint;
	ALPHA = COLOR.a;
}