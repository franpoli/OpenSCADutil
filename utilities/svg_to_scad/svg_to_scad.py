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
        '-c', '--close', 
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
    parser.add_argument(
        '-r', '--rotate', 
        type=float, 
        help='Rotate the coordinates by the specified angle (in degrees).'
    )
    parser.add_argument(
        '-g', '--center-of-gravity', 
        action='store_true', 
        help='Center the coordinates at the center of gravity of the shape.'
    )
    parser.add_argument(
        '-C', '--center',
        action='store_true',
        help='Center the shape at the origin based on the bounding rectangle.'
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

def rotate_coordinates(coordinates, angle):
    angle_rad = np.radians(angle % 360)
    rotation_matrix = np.array([
        [np.cos(angle_rad), -np.sin(angle_rad)],
        [np.sin(angle_rad), np.cos(angle_rad)]
    ])
    coordinates = np.dot(coordinates, rotation_matrix)
    return coordinates.tolist()

def calculate_center_of_gravity(coordinates):
    coordinates = np.array(coordinates)
    centroid = np.mean(coordinates, axis=0)
    return centroid

def center_coordinates_at_gravity(coordinates):
    centroid = calculate_center_of_gravity(coordinates)
    coordinates = np.array(coordinates)
    coordinates -= centroid
    return coordinates.tolist()

def center_coordinates_at_origin(coordinates):
    coordinates = np.array(coordinates)
    x_min, y_min = np.min(coordinates, axis=0)
    x_max, y_max = np.max(coordinates, axis=0)
    x_center = (x_min + x_max) / 2
    y_center = (y_min + y_max) / 2
    coordinates[:, 0] -= x_center
    coordinates[:, 1] -= y_center
    return coordinates.tolist()

def svg_to_coordinates(svg_file, num_samples, close, flip, scale, rotate, center_of_gravity, center):
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
    
    if close and coordinates:
        if coordinates[0] != coordinates[-1]:
            coordinates.append(coordinates[0])

    # By default, flip the coordinates along the y-axis to account for SVG coordinate system
    coordinates = np.array(coordinates)
    y_mean = np.mean(coordinates[:, 1])
    coordinates[:, 1] = 2 * y_mean - coordinates[:, 1]

    # Flip the coordinates if requested
    if flip:
        if flip == 'x':
            y_mean = np.mean(coordinates[:, 1])
            coordinates[:, 1] = 2 * y_mean - coordinates[:, 1]
        elif flip == 'y':
            x_mean = np.mean(coordinates[:, 0])
            coordinates[:, 0] = 2 * x_mean - coordinates[:, 0]
    coordinates = coordinates.tolist()

    # Scale the coordinates if requested
    if scale:
        x_scale, y_scale = parse_scale(scale)
        coordinates = scale_coordinates(coordinates, x_scale, y_scale)
    
    # Rotate the coordinates if requested
    if rotate is not None:
        coordinates = rotate_coordinates(np.array(coordinates), rotate)

    # Center the coordinates at the center of gravity if requested
    if center_of_gravity:
        coordinates = center_coordinates_at_gravity(coordinates)

    # Center the coordinates at the origin based on the bounding rectangle if requested
    if center:
        coordinates = center_coordinates_at_origin(coordinates)

    return coordinates

def plot_coordinates(coordinates):
    coordinates = np.array(coordinates)
    plt.plot(coordinates[:, 0], coordinates[:, 1], 'bo-')  # blue circles with lines
    plt.xlabel('X')
    plt.ylabel('Y')
    plt.title('SVG Path Coordinates')
    plt.grid(True)
    plt.axis('equal')  # Equal scaling for X and Y axes
    plt.show()

def save_as_scad(coordinates, output_file):
    base_name = os.path.splitext(os.path.basename(output_file))[0]
    width = np.max(np.array(coordinates)[:, 0]) - np.min(np.array(coordinates)[:, 0])
    height = np.max(np.array(coordinates)[:, 1]) - np.min(np.array(coordinates)[:, 1])
    with open(output_file, 'w') as f:
        f.write(f"// Width: {width}\n")
        f.write(f"// Height: {height}\n")
        f.write(f"module {base_name}() {{\n")
        f.write(f"    polygon(points=[\n")
        for point in coordinates:
            f.write(f"        [{point[0]}, {point[1]}],\n")
        f.write(f"    ]);\n")
        f.write(f"}}\n")

def save_coordinates(coordinates, output_file):
    ext = os.path.splitext(output_file)[1]
    if ext == '.json':
        with open(output_file, 'w') as f:
            json.dump(coordinates, f)
        print(f"Coordinates saved to {output_file}")
    elif ext == '.scad' or ext == '':
        if ext == '':
            output_file += '.scad'
        save_as_scad(coordinates, output_file)
        print(f"Coordinates saved to {output_file}")
    else:
        raise ValueError("Invalid file extension. Use '.json' or '.scad'.")

def main():
    args = parse_arguments()
    
    # Convert the SVG to coordinates
    coordinates = svg_to_coordinates(args.input, args.number_samples, args.close, args.flip, args.scale, args.rotate, args.center_of_gravity, args.center)

    # Print the width and height
    coordinates_array = np.array(coordinates)
    width = np.max(coordinates_array[:, 0]) - np.min(coordinates_array[:, 0])
    height = np.max(coordinates_array[:, 1]) - np.min(coordinates_array[:, 1])
    print(f"Width: {width}")
    print(f"Height: {height}")

    # Save the coordinates to the appropriate format
    save_coordinates(coordinates, args.output)

    # Plot the coordinates
    plot_coordinates(coordinates)

if __name__ == "__main__":
    main()
