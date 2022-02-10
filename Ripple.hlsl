#ifndef MYHLSLINCLUDE_UNCLUDED
#define MYHLSLINCLUDE_UNCLUDED

float4 CalculateGlow_float(float3 BallPoint, float3 VertexPoint, float BaseOpacity, float ObjectSize, float4 GlowColor, float4 OriginalColor) {
	float distanceFromBall = distance(BallPoint, VertexPoint) / (float)(7.5 * ObjectSize);
	if (distanceFromBall >= 1) {
		float4 color = OriginalColor;
		color.a = BaseOpacity;
		return color;
	}
	float factor = clamp(1 - distanceFromBall, 0, 1);
	factor = pow(factor, 4);
	factor = clamp(factor, 0, 1);
	float4 vertexColor = lerp(OriginalColor, GlowColor, factor);
	float alpha = clamp(1 - distanceFromBall, BaseOpacity, 1);
	vertexColor.a = alpha;
	return vertexColor;
}

// These params are passed through ShaderGraph, the result will be delivered through Out
// ObjectSize should be a float that represents the size of the object in your world, typically Unity's units (Some calculation from collider.bounds might be good) 
void CalculateRipple_float(float3 RipplePoint, float3 VertexPoint, float BaseOpacity, float ObjectSize, float RippleRadius, float RipplePower, float4 RippleColor, float4 OriginalColor, bool RippleAlive, float4 BallPoint, out float4 Out) {
	OriginalColor = CalculateGlow_float(BallPoint, VertexPoint, BaseOpacity, ObjectSize, RippleColor, OriginalColor);
	if (!RippleAlive) {
		Out = OriginalColor;
		return;
	}
 
	float distanceFromRipple = distance(RipplePoint, VertexPoint) / (float)(7.5 * ObjectSize);
	float factor = abs(RippleRadius - distanceFromRipple);
	factor = 1 - (RipplePower / 1.5) - factor;
	if (factor <= 0) {
		Out = OriginalColor;
		return;
	}

	float powerComponent = (1 - RipplePower) * 10;
	factor = pow(factor, powerComponent) * RipplePower;
	factor = clamp(factor, 0, 1);
	float alpha = max(factor, BaseOpacity);

	float4 vertexColor = lerp(OriginalColor, RippleColor, factor);
	vertexColor.a = alpha;
	Out = vertexColor;
	return;
}
#endif
