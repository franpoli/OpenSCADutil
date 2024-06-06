#!/usr/bin/env python3
import argparse
import svgpathtools
import numpy as np
import json
import matplotlib.pyplot as plt
import os

def parse_arguments():
    parser = argparse.ArgumentParser(
        description='Convert SVG paths to a list of coordinates for use in OpenSCAD.'
    )
    parser.add_argument(
        '-i', '--input', 
        type=str, 
        required=True, 
        help='Path to the SVG file.'
    )
    parser.add_argument(
        '-n', '--number-samples', 
        type=int, 
        default=100, 
        help='Number of samples for Bezier curves and arcs (default: 100).'
    )
    parser.add_argument(
        '-o', '--output', 
        type=str, 
        default='coordinates.scad', 
        help='Output file name (default: coordinates.scad).'
    )
    parser.add_argument(
        '-c', '--closed', 
        action='store_true', 
        help='Close the path by adding the first point to the end if not already closed.'
    )
    parser.add_argument(
        '-f', '--flip', 
        type=str, 
        choices=['x', 'y'], 
        help='Flip the coordinates either horizontally or vertically.'
    )
    parser.add_argument(
        '-s', '--scale', 
        type=str, 
        help='Scale the coordinates. Format: x:y, x:, or :y'
    )
    
    return parser.parse_args()

def sample_segment(segment, num_samples):
    t_values = np.linspace(0, 1, num_samples)
    points = []
    for t in t_values:
        point = segment.point(t)
        points.append([point.real, point.imag])
    return points

def parse_scale(scale):
    x_scale, y_scale = None, None
    if ':' in scale:
        parts = scale.split(':')
        if len(parts) == 2:
            x_scale = float(parts[0]) if parts[0] else None
            y_scale = float(parts[1]) if parts[1] else None
    return x_scale, y_scale

def scale_coordinates(coordinates, x_scale, y_scale):
    coordinates = np.array(coordinates)
    x_min, y_min = np.min(coordinates, axis=0)
    x_max, y_max = np.max(coordinates, axis=0)
    x_range = x_max - x_min
    y_range = y_max - y_min

    if x_scale and y_scale:
        x_factor = x_scale / x_range
        y_factor = y_scale / y_range
    elif x_scale:
        x_factor = x_scale / x_range
        y_factor = x_factor
    elif y_scale:
        y_factor = y_scale / y_range
        x_factor = y_factor

    coordinates[:, 0] = (coordinates[:, 0] - x_min) * x_factor
    coordinates[:, 1] = (coordinates[:, 1] - y_min) * y_factor

    return coordinates.tolist()

def svg_to_coordinates(svg_file, num_samples, closed, flip, scale):
    paths, attributes, svg_attributes = svgpathtools.svg2paths2(svg_file)
    coordinates = []
    
    for path in paths:
        for segment in path:
            if isinstance(segment, svgpathtools.Line):
                coordinates.append([segment.start.real, segment.start.imag])
                coordinates.append([segment.end.real, segment.end.imag])
            elif isinstance(segment, (svgpathtools.CubicBezier, svgpathtools.QuadraticBezier, svgpathtools.Arc)):
                coordinates.extend(sample_segment(segment, num_samples))
            # Add other segment types if needed
    
    if closed and coordinates:
        if coordinates[0] != coordinates[-1]:
            coordinates.append(coordinates[0])

    # Flip the coordinates if requested
    if flip:
        coordinates = np.array(coordinates)
        if flip == 'y':
            y_mean = np.mean(coordinates[:, 0])
            coordinates[:, 0] = 2 * y_mean - coordinates[:, 0]
        elif flip == 'x':
            x_mean = np.mean(coordinates[:, 1])
            coordinates[:, 1] = 2 * x_mean - coordinates[:, 1]
        coordinates = coordinates.tolist()

    # Scale the coordinates if requested
    if scale:
        x_scale, y_scale = parse_scale(scale)
        coordinates = scale_coordinates(coordinates, x_scale, y_scale)

    return coordinates

def calculate_width_height(coordinates):
    coordinates = np.array(coordinates)
    x_min, y_min = np.min(coordinates, axis=0)
    x_max, y_max = np.max(coordinates, axis=0)
    width = x_max - x_min
    height = y_max - y_min
    return width, height

def plot_coordinates(coordinates):
    coordinates = np.array(coordinates)
    plt.plot(coordinates[:, 0], coordinates[:, 1], 'bo-')  # blue circles with lines
    plt.xlabel('X')
    plt.ylabel('Y')
    plt.title('SVG Path Coordinates')
    plt.grid(True)
    plt.axis('equal')  # Equal scaling for X and Y axes
    plt.show()

def save_as_scad(coordinates, output_file, width, height):
    base_name = os.path.splitext(os.path.basename(output_file))[0]
    with open(output_file, 'w') as f:
        f.write(f"// Width: {width}, Height: {height}\n")
        f.write(f"module {base_name}() {{\n")
        f.write(f"    polygon(points=[\n")
        for point in coordinates:
            f.write(f"        [{point[0]}, {point[1]}],\n")
        f.write("    ]);\n")
        f.write("}\n")

def save_coordinates(coordinates, output_file):
    ext = os.path.splitext(output_file)[1]
    width, height = calculate_width_height(coordinates)
    if ext == '.json':
        with open(output_file, 'w') as f:
            json.dump(coordinates, f)
        print(f"Coordinates saved to {output_file}")
    elif ext == '.scad' or ext == '':
        if ext == '':
            output_file += '.scad'
        save_as_scad(coordinates, output_file, width, height)
        print(f"Coordinates saved to {output_file}")
    else:
        raise ValueError("Invalid file extension. Use '.json' or '.scad'.")

def main():
    args = parse_arguments()
    
    # Convert the SVG to coordinates
    coordinates = svg_to_coordinates(args.input, args.number_samples, args.closed, args.flip, args.scale)

    # Calculate width and height
    width, height = calculate_width_height(coordinates)
    print(f"Width: {width}, Height: {height}")

    # Save the coordinates to the appropriate format
    save_coordinates(coordinates, args.output)

    # Plot the coordinates
    plot_coordinates(coordinates)

if __name__ == "__main__":
    main()
