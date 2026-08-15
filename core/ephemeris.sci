// OrbitalMDT :: Planetary Ephemeris Engine
// Heliocentric positions & velocities from J2000 mean elements + centennial rates.
// Ref: JPL Solar System Dynamics, Standish (1992).
// Frame: ecliptic J2000.  Valid roughly within +/- 100 years of J2000.
// Accuracy: ~0.1 deg inner planets, ~1 deg outer planets.

function elements = get_planet_elements(planet_id, JD)
    // Orbital elements at Julian Date JD.
    // planet_id: 1=Mercury, 2=Venus, 3=Earth, 4=Mars, 5=Jupiter, 6=Saturn
    // Returns struct: a [AU], e, i [deg], RAAN [deg], omega_bar [deg], L [deg]

    if planet_id < 1 | planet_id > 6 then
        error("get_planet_elements: planet_id must be 1-6");
    end

    T = jd_to_centuries_j2000(JD);

    // [a0, e0, i0, RAAN0, omega_bar0, L0]  (AU, degrees)
    // [a_dot, e_dot, i_dot, RAAN_dot, omega_bar_dot, L_dot]  (per century)
    elem0 = zeros(6, 6);
    rate  = zeros(6, 6);

    elem0(1,:) = [0.38709893, 0.20563069, 7.00487,  48.33167,  77.45645,  252.25084];
    rate(1,:)  = [0.00000066, 0.00002527, -23.51/3600, -446.30/3600, 573.57/3600, 538101628.29/3600];

    elem0(2,:) = [0.72333199, 0.00677323, 3.39471,  76.68069,  131.53298, 181.97973];
    rate(2,:)  = [0.00000092, -0.00004938, -2.86/3600, -996.89/3600, -108.80/3600, 210664136.06/3600];

    elem0(3,:) = [1.00000011, 0.01671022, 0.00005, -11.26064, 102.94719, 100.46435];
    rate(3,:)  = [-0.00000005, -0.00003804, -46.94/3600, -18228.25/3600, 1198.28/3600, 129597740.63/3600];

    elem0(4,:) = [1.52366231, 0.09341233, 1.85061,  49.57854,  336.04084, 355.45332];
    rate(4,:)  = [-0.00007221, 0.00011902, -25.47/3600, -1020.19/3600, 1560.78/3600, 68905103.78/3600];

    elem0(5,:) = [5.20336301, 0.04839266, 1.30530, 100.55615,  14.75385,  34.40438];
    rate(5,:)  = [0.00060737, -0.00012880, -4.15/3600, 1217.17/3600, 839.93/3600, 10925078.35/3600];

    elem0(6,:) = [9.53707032, 0.05415060, 2.48446, 113.71504,  92.43194,  49.94432];
    rate(6,:)  = [-0.00301530, -0.00036762, 6.11/3600, -1591.05/3600, -1948.89/3600, 4401052.95/3600];

    elements.a         = elem0(planet_id, 1) + rate(planet_id, 1) * T;
    elements.e         = elem0(planet_id, 2) + rate(planet_id, 2) * T;
    elements.i         = elem0(planet_id, 3) + rate(planet_id, 3) * T;
    elements.RAAN      = elem0(planet_id, 4) + rate(planet_id, 4) * T;
    elements.omega_bar = elem0(planet_id, 5) + rate(planet_id, 5) * T;
    elements.L         = elem0(planet_id, 6) + rate(planet_id, 6) * T;
endfunction


function [r_vec, v_vec] = planet_state_heliocentric(planet_id, JD)
    // Heliocentric position [km] and velocity [km/s] in ecliptic J2000.

    const = orbital_constants();
    el = get_planet_elements(planet_id, JD);

    d2r = const.deg2rad;
    i_rad    = el.i * d2r;
    RAAN_rad = el.RAAN * d2r;
    omega_rad = (el.omega_bar - el.RAAN) * d2r;

    M = modulo((el.L - el.omega_bar) * d2r, 2*%pi);
    if M < 0 then M = M + 2*%pi; end

    [E, kinfo] = solve_kepler(M, el.e);
    nu = eccentric_to_true(E, el.e);

    a_km = el.a * const.AU;
    [r_vec, v_vec] = orbital_elements_to_state(a_km, el.e, i_rad, ..
                                                RAAN_rad, omega_rad, nu, const.mu_Sun);
endfunction


function positions = solar_system_state(JD)
    // 3x6 matrix: heliocentric positions [km] for Mercury..Saturn.
    positions = zeros(3, 6);
    for k = 1:6
        [r_vec, v_tmp] = planet_state_heliocentric(k, JD);
        positions(:, k) = r_vec;
    end
endfunction
