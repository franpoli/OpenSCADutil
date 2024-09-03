use <pipe_locks_generator.scad>

size = 110;

// DEBUG
difference() {
  union() {
    threaded_collar();
    locking_lid();
  }

  translate([-size/2, 0, -size/4])
  cube([size, size, size]);
}
