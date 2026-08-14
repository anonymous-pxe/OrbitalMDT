// ============================================================================
// OrbitalMDT — Coordinate Transformations
// ============================================================================
// Orbital elements ↔ State vectors, ecliptic ↔ equatorial, etc.
// ============================================================================

function [r_vec, v_vec] = orbital_elements_to_state(a, e, i, RAAN, omega, nu, mu)
    // Convert classical orbital elements to position & velocity vectors
    // INPUTS:
    //   a     - Semi-major axis [km]
    //   e     - Eccentricity
    //   i     - Inclination [rad]
    //   RAAN  - Right ascension of ascending node [rad]
    //   omega - Argument of periapsis [rad]
    //   nu    - True anomaly [rad]
    //   mu    - Gravitational parameter [km^3/s^2]
    // OUTPUTS:
    //   r_vec - Position vector [km] (3x1)
    //   v_vec - Velocity vector [km/s] (3x1)
    
    // Semi-latus rectum
    p = a * (1 - e^2);
    
    // Distance
    r = p / (1 + e * cos(nu));
    
    // Position and velocity in perifocal frame (PQW)
    r_pqw = [r * cos(nu); r * sin(nu); 0];
    v_pqw = sqrt(mu/p) * [-sin(nu); (e + cos(nu)); 0];
    
    // Rotation matrix: perifocal → inertial (ECI)
    R = rotation_matrix_313(RAAN, i, omega);
    
    // Transform
    r_vec = R * r_pqw;
    v_vec = R * v_pqw;
    
endfunction


function [a, e, i, RAAN, omega, nu] = state_to_orbital_elements(r_vec, v_vec, mu)
    // Convert state vectors to classical orbital elements
    // INPUTS:
    //   r_vec - Position vector [km] (3x1)
    //   v_vec - Velocity vector [km/s] (3x1)
    //   mu    - Gravitational parameter [km^3/s^2]
    // OUTPUTS:
    //   a     - Semi-major axis [km]
    //   e     - Eccentricity
    //   i     - Inclination [rad]
    //   RAAN  - Right ascension of ascending node [rad]
    //   omega - Argument of periapsis [rad]
    //   nu    - True anomaly [rad]
    
    r = norm(r_vec);
    v = norm(v_vec);
    
    // Specific angular momentum
    h_vec = cross(r_vec, v_vec);
    h = norm(h_vec);
    
    // Node vector
    K = [0; 0; 1];
    n_vec = cross(K, h_vec);
    n = norm(n_vec);
    
    // Eccentricity vector
    e_vec = (1/mu) * ((v^2 - mu/r) * r_vec - dot(r_vec, v_vec) * v_vec);
    e = norm(e_vec);
    
    // Specific energy → semi-major axis
    energy = v^2/2 - mu/r;
    if abs(e - 1.0) > 1e-10 then
        a = -mu / (2 * energy);
    else
        a = %inf;  // Parabolic
    end
    
    // Inclination
    i = acos(h_vec(3) / h);
    
    // RAAN
    if n > 1e-10 then
        RAAN = acos(n_vec(1) / n);
        if n_vec(2) < 0 then RAAN = 2*%pi - RAAN; end
    else
        RAAN = 0;
    end
    
    // Argument of periapsis
    if n > 1e-10 & e > 1e-10 then
        omega = acos(dot(n_vec, e_vec) / (n * e));
        if e_vec(3) < 0 then omega = 2*%pi - omega; end
    else
        omega = 0;
    end
    
    // True anomaly
    if e > 1e-10 then
        nu = acos(dot(e_vec, r_vec) / (e * r));
        if dot(r_vec, v_vec) < 0 then nu = 2*%pi - nu; end
    else
        nu = 0;
    end
    
endfunction


function R = rotation_matrix_313(phi1, theta, phi2)
    // 3-1-3 Euler rotation matrix (Ω, i, ω)
    // Used to transform from perifocal to inertial frame
    
    c1 = cos(phi1); s1 = sin(phi1);
    ct = cos(theta); st = sin(theta);
    c2 = cos(phi2); s2 = sin(phi2);
    
    R = [c1*c2-s1*s2*ct,  -c1*s2-s1*c2*ct,  s1*st;
         s1*c2+c1*s2*ct,  -s1*s2+c1*c2*ct, -c1*st;
         s2*st,             c2*st,            ct];
    
endfunction


function r_eq = ecliptic_to_equatorial(r_ecl)
    // Transform from ecliptic to equatorial coordinates
    // Using J2000 obliquity of the ecliptic: 23.4393°
    
    eps = 23.4393 * %pi / 180;
    
    R_ecl2eq = [1,    0,        0;
                0,  cos(eps), -sin(eps);
                0,  sin(eps),  cos(eps)];
    
    r_eq = R_ecl2eq * r_ecl;
    
endfunction


function [lat, lon, alt] = eci_to_geodetic(r_vec, t, omega_earth)
    // Convert ECI position to geodetic latitude, longitude, altitude
    // INPUTS:
    //   r_vec       - ECI position vector [km] (3x1)
    //   t           - Time since epoch [s]
    //   omega_earth - Earth rotation rate [rad/s]
    // OUTPUTS:
    //   lat - Geodetic latitude [rad]
    //   lon - Longitude [rad]
    //   alt - Altitude above mean spherical Earth [km]
    
    const = orbital_constants();
    
    r = norm(r_vec);
    
    // Latitude (simplified spherical)
    lat = asin(r_vec(3) / r);
    
    // Greenwich sidereal angle
    theta_G = modulo(omega_earth * t, 2*%pi);
    
    // Longitude (inertial → rotating)
    lon = atan(r_vec(2), r_vec(1)) - theta_G;
    lon = modulo(lon + %pi, 2*%pi) - %pi;  // Wrap to [-pi, pi]
    
    // Altitude
    alt = r - const.Re_Earth;
    
endfunction


function v_circ = circular_velocity(mu, r)
    // Circular orbital velocity at radius r
    v_circ = sqrt(mu / r);
endfunction


function T = orbital_period(a, mu)
    // Orbital period for elliptic orbit
    T = 2 * %pi * sqrt(a^3 / mu);
endfunction


function v_esc = escape_velocity(mu, r)
    // Escape velocity at radius r
    v_esc = sqrt(2 * mu / r);
endfunction
