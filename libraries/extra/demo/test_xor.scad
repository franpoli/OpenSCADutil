use<extra.scad>

function test_xor() = [
    [true, true, xor(true, true)],    // Expected false
    [true, false, xor(true, false)],  // Expected true
    [false, true, xor(false, true)],  // Expected true
    [true, true, xor(true, true)],    // Expected false
];

// Print results
for (t = test_xor()) 
    echo("A: ", t[0], " B: ", t[1], " XOR: ", t[2]);
