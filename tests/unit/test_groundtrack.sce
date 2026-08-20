// OrbitalMDT Unit Test :: Satellite Ground Track Computation
// Validates sub-satellite latitude/longitude computation and Prime Meridian / Date Line wrapping.

exec("core/constants.sci", -1);
exec("core/groundtrack.sci", -1);

m_passed = 0;
m_failed = 0;

function assert_true(cond, name)
    global m_passed m_failed;
    if cond then
        m_passed = m_passed + 1;
        printf("  [PASS] %s\n", name);
    else
        m_failed = m_failed + 1;
        printf("  [FAIL] %s\n", name);
    end
endfunction

printf("--- Running unit/test_groundtrack.sce ---\n");

const = orbital_constants();
omega_e = const.omega_Earth;

// 1. Equatorial circular trajectory at t=0
// Position on X axis -> Lat = 0, Lon = 0
states_eq = [7000; 0; 0; 0; 7.5; 0];
t_0 = [0];

[lat_0, lon_0] = compute_ground_track(states_eq, t_0, omega_e);
assert_true(abs(lat_0(1)) < 1e-6, "Equatorial position latitude is 0 deg");
assert_true(abs(lon_0(1)) < 1e-6, "Position on X-axis at t=0 longitude is 0 deg (Prime Meridian)");

// 2. Polar position (Z axis)
states_pole = [0; 0; 7000; 0; 0; 0];
[lat_pole, lon_pole] = compute_ground_track(states_pole, [0], omega_e);
assert_true(abs(lat_pole(1) - 90.0) < 1e-6, "North pole position latitude is +90 deg");

// 3. Multi-point state array longitude bounds in [-180, 180]
N = 100;
t_vec = linspace(0, 86400, N);
states_circ = zeros(6, N);
for k = 1:N
    th = 2*%pi * k / N;
    states_circ(:, k) = [7000*cos(th); 7000*sin(th); 0; -7.5*sin(th); 7.5*cos(th); 0];
end

[lat_arr, lon_arr] = compute_ground_track(states_circ, t_vec, omega_e);

assert_true(size(lat_arr, "*") == N & size(lon_arr, "*") == N, "Ground track output array length matches input");
assert_true(and(lat_arr >= -90 & lat_arr <= 90), "All latitudes within [-90, +90] deg");
assert_true(and(lon_arr >= -180 & lon_arr <= 180), "All longitudes within [-180, +180] deg");

printf("  Result: %d Passed, %d Failed\n\n", m_passed, m_failed);
