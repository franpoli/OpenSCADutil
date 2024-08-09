use <extra.scad>

point1 = [2, 3];
point2 = [15, 21];

slope = slope(point1, point2);
perpendicular_slope = perpendicular_slope(slope);

echo("slope", slope);
echo("perpendicular slope", perpendicular_slope);
