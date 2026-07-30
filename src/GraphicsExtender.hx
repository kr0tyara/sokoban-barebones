import h2d.Graphics;
import Dir.ExtendDir;

class GraphicsExtender extends Graphics
{
	public function drawRoundedRectCorners( x : Float, y : Float, w : Float, h : Float, radius : Float, neighbours:Map<Dir, Bool>, diagonals:Map<ExtendDir, Bool> = null, nsegments = 0)
    {
		if (radius <= 0) {
			return drawRect(x, y, w, h);
		}

		var diag = diagonals != null;
		var diagRadius = radius / 2;

		x += radius;
		y += radius;
		w -= radius * 2;
		h -= radius * 2;
		flush();
		if( nsegments == 0 )
			nsegments = Math.ceil(Math.abs(radius * hxd.Math.degToRad(90) / 4));
		if( nsegments < 3 ) nsegments = 3;
		var angle = hxd.Math.degToRad(90) / (nsegments - 1);
		
		inline function corner(x:Float, y:Float, angleStart, reverse = false)
		{
			if (reverse) {
				var midAngle = hxd.Math.degToRad(angleStart + 45);
				var cx = x + Math.cos(midAngle) * radius * Math.sqrt(2);
				var cy = y + Math.sin(midAngle) * radius * Math.sqrt(2);

				var startAngle = hxd.Math.degToRad(angleStart - 90);
				for (i in 0...nsegments) {
					var a = startAngle - i * angle;
					lineTo(cx + Math.cos(a) * radius, cy + Math.sin(a) * radius);
				}
			} 
			else
			{
				for (i in 0...nsegments)
				{
					var a = i * angle + hxd.Math.degToRad(angleStart);
					lineTo(x + Math.cos(a) * radius, y + Math.sin(a) * radius);
				}
			}

		}
		lineTo(x, y - radius);
		lineTo(x + w, y - radius);

		if(diag && neighbours[Dir.Up] && neighbours[Dir.Right] && !diagonals[ExtendDir.UpRight])
            corner(x + w + diagRadius, y - diagRadius, 270, true);
		else if(neighbours[Dir.Up] || neighbours[Dir.Right])
            lineTo(x + w + radius, y - radius);
        else
            corner(x + w, y, 270);
		
        lineTo(x + w + radius, y + h);
        
		if(diag && neighbours[Dir.Down] && neighbours[Dir.Right] && !diagonals[ExtendDir.DownRight])
            corner(x + w + diagRadius, y + h + diagRadius, 0, true);
		else if(neighbours[Dir.Down] || neighbours[Dir.Right])
            lineTo(x + w + radius, y + h + radius);
        else
            corner(x + w, y + h, 0);

		lineTo(x, y + h + radius);
        
		if(diag && neighbours[Dir.Down] && neighbours[Dir.Left] && !diagonals[ExtendDir.DownLeft])
            corner(x - diagRadius, y + h + diagRadius, 90, true);
		else if(neighbours[Dir.Down] || neighbours[Dir.Left])
            lineTo(x - radius, y + h + radius);
        else
            corner(x, y + h, 90);

		lineTo(x - radius, y);

		if(diag && neighbours[Dir.Up] && neighbours[Dir.Left] && !diagonals[ExtendDir.UpLeft])
            corner(x - diagRadius, y - diagRadius, 180, true);
        else if(neighbours[Dir.Up] || neighbours[Dir.Left])
            lineTo(x - radius, y - radius);
        else
            corner(x, y, 180);
		flush();
	}

	public function drawRoundedRectVCorners( x : Float, y : Float, w : Float, h : Float, radii : Array<Float>, neighbours:Map<Dir, Bool>, nsegments = 0 )
	{
		var rTL = radii.length > 0 ? radii[0] : 0.0;
		var rTR = radii.length > 1 ? radii[1] : rTL;
		var rBR = radii.length > 2 ? radii[2] : rTL;
		var rBL = radii.length > 3 ? radii[3] : rTR;

		var maxR = Math.max(Math.max(rTL, rTR), Math.max(rBR, rBL));

		if (maxR <= 0)
			return drawRect(x, y, w, h);

		flush();

		if (nsegments == 0)
			nsegments = Math.ceil(Math.abs(maxR * hxd.Math.degToRad(90) / 4));
		if (nsegments < 3) nsegments = 3;

		var baseAngle = hxd.Math.degToRad(90) / (nsegments - 1);

		inline function corner(cx:Float, cy:Float, r:Float, angleStart:Float) {
			if (r <= 0) {
				lineTo(cx, cy);
				return;
			}
			for (i in 0...nsegments) {
				var a = i * baseAngle + hxd.Math.degToRad(angleStart);
				lineTo(cx + Math.cos(a) * r, cy + Math.sin(a) * r);
			}
		}

		// up
		lineTo(x + rTL,     y);
		lineTo(x + w - rTR, y);

		// right up
		if (neighbours[Dir.Up] || neighbours[Dir.Right])
			lineTo(x + w, y);
		else
			corner(x + w - rTR, y + rTR, rTR, 270);

		// right
		lineTo(x + w, y + h - rBR);

		// right down
		if (neighbours[Dir.Down] || neighbours[Dir.Right])
			lineTo(x + w, y + h);
		else
			corner(x + w - rBR, y + h - rBR, rBR, 0);

		// down
		lineTo(x + rBL, y + h);

		// left down
		if (neighbours[Dir.Down] || neighbours[Dir.Left])
			lineTo(x, y + h);
		else
			corner(x + rBL, y + h - rBL, rBL, 90);

		// left
		lineTo(x, y + rTL);

		// left up
		if (neighbours[Dir.Up] || neighbours[Dir.Left])
			lineTo(x, y);
		else
			corner(x + rTL, y + rTL, rTL, 180);

		flush();
	}
}