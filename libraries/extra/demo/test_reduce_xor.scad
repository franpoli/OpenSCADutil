use<extra.scad>

// Example test for reduce_xor
function test_reduce_xor() = [
    [ [true, true], true ], // 
    [ [true, false], true ],
    [ [false, true], true ],
    [ [false, false], false ],
    [ [true, false, true], true ],  // (true XOR false) XOR true = true
    [ [true, false, false], false ], // (true XOR false) XOR false = false
];

for (test = test_reduce_xor()) {
    result = reduce_xor(test[0]);
    echo("Input: ", test[0], " Expected: ", test[1], " Got: ", result);
    assert(result == test[1], "Test failed!");
}
