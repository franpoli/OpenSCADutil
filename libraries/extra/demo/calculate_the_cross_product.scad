use <extra.scad>

v1 = [20, 0, 0];
v2 = [-10, 1.2, 0];

v1_x_v2 = cross(v1, v2);

echo("v1 x v2", v1_x_v2);
