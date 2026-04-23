import Utils.Dir;
import h2d.Graphics;

class GraphicsExtender extends Graphics
{
	public function drawRoundedRectCorners( x : Float, y : Float, w : Float, h : Float, radius : Float, neighbours:Map<Dir, Bool>, nsegments = 0 )
    {
		if (radius <= 0) {
			return drawRect(x, y, w, h);
		}
		x += radius;
		y += radius;
		w -= radius * 2;
		h -= radius * 2;
		flush();
		if( nsegments == 0 )
			nsegments = Math.ceil(Math.abs(radius * hxd.Math.degToRad(90) / 4));
		if( nsegments < 3 ) nsegments = 3;
		var angle = hxd.Math.degToRad(90) / (nsegments - 1);
		inline function corner(x, y, angleStart) {
		for ( i in 0...nsegments) {
			var a = i * angle + hxd.Math.degToRad(angleStart);
			lineTo(x + Math.cos(a) * radius, y + Math.sin(a) * radius);
		}
		}

		lineTo(x, y - radius);
		lineTo(x + w, y - radius);

        if(neighbours[Dir.Up] || neighbours[Dir.Right])
            lineTo(x + w + radius, y - radius);
        else
            corner(x + w, y, 270);
		
        lineTo(x + w + radius, y + h);
        
        if(neighbours[Dir.Down] || neighbours[Dir.Right])
            lineTo(x + w + radius, y + h + radius);
        else
            corner(x + w, y + h, 0);

		lineTo(x, y + h + radius);
        
        if(neighbours[Dir.Down] || neighbours[Dir.Left])
            lineTo(x - radius, y + h + radius);
        else
            corner(x, y + h, 90);

		lineTo(x - radius, y);

        if(neighbours[Dir.Up] || neighbours[Dir.Left])
            lineTo(x - radius, y - radius);
        else
            corner(x, y, 180);

		lineTo(x, y - radius);

		flush();
	}
}