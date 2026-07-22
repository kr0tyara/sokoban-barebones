package shaders;
class Vignette extends hxsl.Shader
{
    static var SRC =
    {
        var output : {
            var color : Vec4;
            var position : Vec4;
        };

        var screenPos : Vec2;

        @param var gradColor : Vec4;
        @param var rect : Vec4;
        @param var softness : Float;
        @param var screenSize : Vec2;

        function vertex()
        {
            screenPos = (output.position.xy * vec2(0.5, -0.5) + 0.5) * screenSize;
        }

        function fragment()
        {
            var center = rect.xy + rect.zw * 0.5;
            var halfSize = rect.zw * 0.5;

            var d = abs(screenPos - center) / halfSize;
            var dist = max(d.x, d.y);
            var blend = smoothstep(1.0 - softness, 1.0, dist);

            var overlayAlpha = gradColor.a * blend;

            var overlay = vec4(gradColor.rgb * overlayAlpha, overlayAlpha);

            output.color = overlay + output.color * (1.0 - overlayAlpha);
        }
    };
}