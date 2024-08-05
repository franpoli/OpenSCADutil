use <extra.scad>

point1 = [3, 6, 9];
point2 = [33, 66, 99];

v = vector(point1, point2);
n = norm(v);

echo("Vector v", v);
echo("norm(v)", n);
