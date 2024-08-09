use <extra.scad>

// One-dimensional vector
vec_1_dim = [11];
// Two-dimensional vector
vec_2_dim = [15, 10];
// Three-dimensional vector
vec_3_dim = [20, -15, -10];
// Four-dimensional vector
vec_4_dim = [-5, 9, 10, 12];

vectors = [vec_1_dim, vec_2_dim, vec_3_dim, vec_4_dim]; 

for (vector = vectors) {
  echo(vector, pad_to_three(vector));
}
