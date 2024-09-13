# TDOA- and RSSI-based sound source localization

TThis project automates the experiments for 3D sound source localization based on Time Difference of Arrival (TDOA) and Received Signal Strength Indicator (RSSI, power ratios) measurements. The main file, `get_all_results.m`, organizes the newly acquired experiment files, runs a transient detector to separate acoustic events, applies GCC-PHAT to measure TDOA, calculates power ratios, and employs the Gauss-Newton non-linear LSE method to infer the sound source position. It also visualizes the entire setup along with the calculated angles of arrival.

Additionally, a grid evaluation of the loss function is performed by discretizing the room into 0.25 m x 0.25 m x 0.25 m cubes. The objective function of the optimization algorithm is then calculated at the center of each cube, and the grid evaluation is visualized with a 3D color map.


