// ============================================================================
// OrbitalMDT — Planetary Ephemeris Engine
// ============================================================================
// Computes heliocentric positions and velocities of planets using
// J2000 mean orbital elements with centennial rates.
// Reference: JPL Solar System Dynamics, Standish (1992)
// ============================================================================

function JD = date_to_jd(year, month, day, hour)
    // Convert calendar date to Julian Date
    // INPUTS:
    //   year, month, day - Calendar date
    //   hour             - Hours (decimal, UT) [default 0]
    // OUTPUT:
    //   JD - Julian Date
    
    if ~exists('hour', 'local') then hour = 0; end
    
    if month <= 2 then
        year  = year - 1;
        month = month + 12;
    end
    
    A = floor(year / 100);
    B = 2 - A + floor(A / 4);
    
    JD = floor(365.25 * (year + 4716)) + floor(30.6001 * (month + 1)) + ...
         day + hour/24.0 + B - 1524.5;
    
endfunction


function [year, month, day] = jd_to_date(JD)
    // Convert Julian Date to calendar date
    
    JD = JD + 0.5;
    Z = floor(JD);
    F = JD - Z;
    
    if Z < 2299161 then
        A = Z;
    else
        alpha = floor((Z - 1867216.25) / 36524.25);
        A = Z + 1 + alpha - floor(alpha / 4);
    end
    
    B = A + 1524;
    C = floor((B - 122.1) / 365.25);
    D = floor(365.25 * C);
    E = floor((B - D) / 30.6001);
    
    day = B - D - floor(30.6001 * E) + F;
    
    if E < 14 then
        month = E - 1;
    else
        month = E - 13;
    end
    
    if month > 2 then
        year = C - 4716;
    else
        year = C - 4715;
    end
    
endfunction


function elements = get_planet_elements(planet_id, JD)
    // Get orbital elements for a planet at a given Julian Date
    // INPUTS:
    //   planet_id - 1=Mercury, 2=Venus, 3=Earth, 4=Mars, 5=Jupiter, 6=Saturn
    //   JD        - Julian Date
    // OUTPUT:
    //   elements  - struct with fields: a, e, i, RAAN, omega_bar, L
    //               (a in AU, angles in degrees)
    
    // Centuries since J2000
    T = (JD - 2451545.0) / 36525.0;
    
    // J2000 mean orbital elements and centennial rates
    // [a0, e0, i0, RAAN0, omega_bar0, L0]
    // [a_dot, e_dot, i_dot, RAAN_dot, omega_bar_dot, L_dot]
    // a in AU, angles in degrees, rates per century
    
    // Mercury
    elem0(1,:) = [0.38709893, 0.20563069, 7.00487,  48.33167,  77.45645,  252.25084];
    rate(1,:)  = [0.00000066, 0.00002527, -23.51/3600, -446.30/3600, 573.57/3600, 538101628.29/3600];
    
    // Venus
    elem0(2,:) = [0.72333199, 0.00677323, 3.39471,  76.68069,  131.53298, 181.97973];
    rate(2,:)  = [0.00000092, -0.00004938, -2.86/3600, -996.89/3600, -108.80/3600, 210664136.06/3600];
    
    // Earth-Moon Barycenter
    elem0(3,:) = [1.00000011, 0.01671022, 0.00005, -11.26064, 102.94719, 100.46435];
    rate(3,:)  = [-0.00000005, -0.00003804, -46.94/3600, -18228.25/3600, 1198.28/3600, 129597740.63/3600];
    
    // Mars
    elem0(4,:) = [1.52366231, 0.09341233, 1.85061,  49.57854,  336.04084, 355.45332];
    rate(4,:)  = [-0.00007221, 0.00011902, -25.47/3600, -1020.19/3600, 1560.78/3600, 68905103.78/3600];
    
    // Jupiter
    elem0(5,:) = [5.20336301, 0.04839266, 1.30530, 100.55615,  14.75385,  34.40438];
    rate(5,:)  = [0.00060737, -0.00012880, -4.15/3600, 1217.17/3600, 839.93/3600, 10925078.35/3600];
    
    // Saturn
    elem0(6,:) = [9.53707032, 0.05415060, 2.48446, 113.71504,  92.43194,  49.94432];
    rate(6,:)  = [-0.00301530, -0.00036762, 6.11/3600, -1591.05/3600, -1948.89/3600, 4401052.95/3600];
    
    // Compute current elements
    elements.a         = elem0(planet_id, 1) + rate(planet_id, 1) * T;  // AU
    elements.e         = elem0(planet_id, 2) + rate(planet_id, 2) * T;
    elements.i         = elem0(planet_id, 3) + rate(planet_id, 3) * T;  // degrees
    elements.RAAN      = elem0(planet_id, 4) + rate(planet_id, 4) * T;  // degrees
    elements.omega_bar = elem0(planet_id, 5) + rate(planet_id, 5) * T;  // degrees
    elements.L         = elem0(planet_id, 6) + rate(planet_id, 6) * T;  // degrees
    
endfunction


function [r_vec, v_vec] = planet_state_heliocentric(planet_id, JD)
    // Compute heliocentric position and velocity of a planet
    // INPUTS:
    //   planet_id - 1-6 (Mercury through Saturn)
    //   JD        - Julian Date
    // OUTPUTS:
    //   r_vec - Heliocentric position [km] (3x1) in ecliptic frame
    //   v_vec - Heliocentric velocity [km/s] (3x1) in ecliptic frame
    
    const = orbital_constants();
    
    // Get orbital elements
    el = get_planet_elements(planet_id, JD);
    
    // Convert to radians
    d2r = %pi / 180;
    i_rad    = el.i * d2r;
    RAAN_rad = el.RAAN * d2r;
    
    // Argument of perihelion
    omega_rad = (el.omega_bar - el.RAAN) * d2r;
    
    // Mean anomaly
    M = modulo((el.L - el.omega_bar) * d2r, 2*%pi);
    if M < 0 then M = M + 2*%pi; end
    
    // Solve Kepler's equation for eccentric anomaly
    E = solve_kepler(M, el.e);
    
    // True anomaly
    nu = eccentric_to_true(E, el.e);
    
    // Semi-major axis in km
    a_km = el.a * const.AU;
    
    // Get state vectors
    [r_vec, v_vec] = orbital_elements_to_state(a_km, el.e, i_rad, RAAN_rad, omega_rad, nu, const.mu_Sun);
    
endfunction


function [positions] = solar_system_state(JD)
    // Get positions of all 6 planets at a given date
    // OUTPUT:
    //   positions - 3x6 matrix, each column is a planet's heliocentric position [km]
    
    positions = zeros(3, 6);
    for k = 1:6
        [r_vec, ~] = planet_state_heliocentric(k, JD);
        positions(:, k) = r_vec;
    end
    
endfunction
