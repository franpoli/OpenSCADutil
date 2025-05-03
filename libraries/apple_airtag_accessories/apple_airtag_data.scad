/* Apple AirTag Profile Dimensions adapted from
 * Accessory Design Guidelines for Apple Devices March 17, 2025
 * https://developer.apple.com/accessories/Accessory-Design-Guidelines.pdf
 *
 * AirTag Profile adapted dimensions. Coordinate ordering matter:
 * - Starts from maximum y (top of the AirTag), at x = 0
 * - Proceeds in decreasing y toward the bottom, with increasing x
 * - Ends at y = 0, x = 0 (bottom center)
 */

AIRTAG_PTS = [
  [0.00, 7.98], [0.83, 7.97], [1.66, 7.96], [2.49, 7.95],
  [3.32, 7.92], [4.15, 7.89], [4.97, 7.85], [5.80, 7.81],
  [6.63, 7.75], [7.45, 7.69], [8.28, 7.62], [9.10, 7.54],
  [9.93, 7.44], [10.75, 7.33], [11.57, 7.20], [12.38, 7.03],
  [13.18, 6.82], [13.96, 6.55], [14.70, 6.18], [15.35, 5.67],
  [15.80, 4.98], [15.93, 4.17], [15.80, 3.36], [15.35, 2.67],
  [14.93, 2.29], [12.78, 2.29], [12.78, 0.88], [11.75, 0.75],
  [10.77, 0.63], [9.80, 0.52], [8.82, 0.42], [7.84, 0.33],
  [6.86, 0.26], [5.89, 0.19], [4.91, 0.13], [3.93, 0.08],
  [2.95, 0.05], [1.96, 0.02], [0.98, 0.01], [0.00, 0.00]
];

function get_airtag_max_x(points) = max([for (pt = points) abs(pt[0])]);
function get_airtag_width() = 2 * get_airtag_max_x(AIRTAG_PTS);
function get_airtag_height() = AIRTAG_PTS[0][1];
function get_airtag_instance_size(clearance = 0) =
  [get_airtag_width() + 2 * clearance,   // x
   get_airtag_width() + 2 * clearance,   // y
   get_airtag_height() + 2 * clearance]; // z

function find_airtag_segments(points, coord_index) = [for (i = [1:len(points)-1])
    if (points[i][coord_index] == points[i-1][coord_index])
      [points[i-1], points[i]]];

function validate_segment(segments, expected_count, segment_type) =
    (len(segments) == expected_count) ? segments[0] : 
        echo(str("WARNING: Expected ",
		 expected_count, " ",
		 segment_type,
		 " segment(s), found ",
		 len(segments)))
        [[0,0],[0,0]];

function get_airtag_staging_info() =
    let(h_seg = validate_segment(find_airtag_segments(AIRTAG_PTS, 1), 1, "horizontal"),
	v_seg = validate_segment(find_airtag_segments(AIRTAG_PTS, 0), 1, "vertical"))
  [h_seg, v_seg];  // Returns clean pairs without extra nesting

function get_airtag_h_seg_length() =
  get_airtag_staging_info()[0][0][0] - get_airtag_staging_info()[0][1][0];
function get_airtag_v_seg_length() =
  get_airtag_staging_info()[1][0][1] - get_airtag_staging_info()[1][1][1];
function get_airtag_h_seg_y_pos(diff = 0) = get_airtag_staging_info()[0][0][1];
function get_airtag_v_seg_x_pos(diff = 0) = get_airtag_staging_info()[0][1][0];
