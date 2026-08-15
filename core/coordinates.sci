// OrbitalMDT :: Coordinate Transformations
// Orbital elements <-> state vectors, rotation matrices, geodetic conversion.
// All angles in radians. All vectors in ecliptic J2000 unless noted.
// Frame transforms (ecliptic<->equatorial) are in frames.sci.

function [r_vec, v_vec] = orbital_elements_to_state(a, e, i, RAAN, omega, nu, mu)
    // Classical orbital elements -> position & velocity vectors.
    // Frame: same as the frame defining (i, RAAN, omega).
    // INPUTS:  a [km], e [-], i [rad], RAAN [rad], omega [rad], nu [rad], mu [km^3/s^2]
    // OUTPUTS: r_vec [km] (3x1), v_vec [km/s] (3x1)

    p = a * (1 - e^2);
    r = p / (1 + e * cos(nu));

    r_pqw = [r * cos(nu); r * sin(nu); 0];
    v_pqw = sqrt(mu / p) * [-sin(nu); e + cos(nu); 0];

    R = rotation_matrix_313(RAAN, i, omega);
    r_vec = R * r_pqw;
    v_vec = R * v_pqw;
endfunction


function [a, e, i, RAAN, omega, nu] = state_to_orbital_elements(r_vec, v_vec, mu)
    // State vectors -> classical orbital elements.
    // INPUTS:  r_vec [km], v_vec [km/s], mu [km^3/s^2]
    // OUTPUTS: a [km], e [-], i [rad], RAAN [rad], omega [rad], nu [rad]

    r = norm(r_vec);
    v = norm(v_vec);

    h_vec = cross(r_vec, v_vec);
    h = norm(h_vec);

    K = [0; 0; 1];
    n_vec = cross(K, h_vec);
    n = norm(n_vec);

    e_vec = (1 / mu) * ((v^2 - mu / r) * r_vec - dot(r_vec, v_vec) * v_vec);
    e = norm(e_vec);

    energy = v^2 / 2 - mu / r;
    if abs(e - 1.0) > 1e-10 then
        a = -mu / (2 * energy);
    else
        a = %inf;
    end

    i = acos(max(-1, min(1, h_vec(3) / h)));

    if n > 1e-10 then
        RAAN = acos(max(-1, min(1, n_vec(1) / n)));
        if n_vec(2) < 0 then RAAN = 2*%pi - RAAN; end
    else
        RAAN = 0;
    end

    if n > 1e-10 & e > 1e-10 then
        cos_w = dot(n_vec, e_vec) / (n * e);
        omega = acos(max(-1, min(1, cos_w)));
        if e_vec(3) < 0 then omega = 2*%pi - omega; end
    else
        omega = 0;
    end

    if e > 1e-10 then
        cos_nu = dot(e_vec, r_vec) / (e * r);
        nu = acos(max(-1, min(1, cos_nu)));
        if dot(r_vec, v_vec) < 0 then nu = 2*%pi - nu; end
    else
        nu = 0;
    end
endfunction


function R = rotation_matrix_313(phi1, theta, phi2)
    // 3-1-3 Euler rotation: perifocal -> inertial.
    // phi1 = RAAN, theta = inclination, phi2 = arg. periapsis.

    c1 = cos(phi1); s1 = sin(phi1);
    ct = cos(theta); st = sin(theta);
    c2 = cos(phi2); s2 = sin(phi2);

    R = [c1*c2 - s1*s2*ct,  -c1*s2 - s1*c2*ct,   s1*st;
         s1*c2 + c1*s2*ct,  -s1*s2 + c1*c2*ct,  -c1*st;
         s2*st,               c2*st,               ct];
endfunction


function [lat, lon, alt] = eci_to_geodetic(r_vec, t, omega_earth)
    // ECI position -> geodetic latitude, longitude, altitude.
    // Simplified spherical model. Frame: equatorial.
    // INPUTS:  r_vec [km] (3x1 ECI), t [s] since epoch, omega_earth [rad/s]
    // OUTPUTS: lat [rad], lon [rad] in [-pi,pi], alt [km]

    const = orbital_constants();
    r = norm(r_vec);

    lat = asin(max(-1, min(1, r_vec(3) / r)));
    theta_G = modulo(omega_earth * t, 2*%pi);
    lon = atan(r_vec(2), r_vec(1)) - theta_G;
    lon = modulo(lon + %pi, 2*%pi) - %pi;
    alt = r - const.Re_Earth;
endfunction


function v_c = circular_velocity(mu, r)
    v_c = sqrt(mu / r);
endfunction


function T = orbital_period(a, mu)
    T = 2 * %pi * sqrt(a^3 / mu);
endfunction


function v_e = escape_velocity(mu, r)
    v_e = sqrt(2 * mu / r);
endfunction
