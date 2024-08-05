use <extra.scad>

p1 = [3, 16, 15];
p2 = [23, 26, 10];
np2 = (-1)*p2;

v = vector_substraction(p1, p2);

echo("Displacement vector", v);
