// OrbitalMDT :: Physical & Astronomical Constants
// Single source of truth for all constants. Units: km, kg, s, rad.

function const = orbital_constants()

    // --- Universal ---
    const.G = 6.67430e-20;                // gravitational constant [km^3/(kg*s^2)]

    // --- Sun ---
    const.mu_Sun = 1.32712440018e11;      // [km^3/s^2]
    const.R_Sun  = 695700;                // [km]

    // --- Planetary gravitational parameters [km^3/s^2] ---
    const.mu_Mercury = 2.2032e4;
    const.mu_Venus   = 3.24859e5;
    const.mu_Earth   = 3.986004418e5;
    const.mu_Mars    = 4.282837e4;
    const.mu_Jupiter = 1.26686534e8;
    const.mu_Saturn  = 3.7931187e7;
    const.mu_Moon    = 4.9048695e3;

    // --- Planetary mean equatorial radii [km] ---
    const.R_Mercury = 2439.7;
    const.R_Venus   = 6051.8;
    const.R_Earth   = 6371.0;
    const.R_Mars    = 3389.5;
    const.R_Jupiter = 69911;
    const.R_Saturn  = 58232;
    const.R_Moon    = 1737.4;

    // --- Mean orbital semi-major axes [km] ---
    const.a_Mercury = 57.909e6;
    const.a_Venus   = 108.21e6;
    const.a_Earth   = 149.598e6;
    const.a_Mars    = 227.956e6;
    const.a_Jupiter = 778.570e6;
    const.a_Saturn  = 1433.53e6;

    // --- Unit conversions ---
    const.AU       = 149597870.7;         // 1 AU [km]
    const.deg2rad  = %pi / 180;
    const.rad2deg  = 180 / %pi;
    const.day2sec  = 86400;               // [s/day]
    const.year2sec = 365.25 * 86400;      // [s/Julian year]
    const.hr2sec   = 3600;                // [s/hr]

    // --- Earth-specific ---
    const.J2_Earth    = 1.08263e-3;       // J2 oblateness
    const.Re_Earth    = 6378.137;         // equatorial radius [km]
    const.Rp_Earth    = 6356.752;         // polar radius [km]
    const.omega_Earth = 7.2921159e-5;     // rotation rate [rad/s]
    const.rho0_Earth  = 1.225e9;          // sea-level air density [kg/km^3]
    const.H_Earth     = 8.5;             // scale height [km]

    // --- Mars-specific ---
    const.J2_Mars    = 1.9555e-3;
    const.omega_Mars = 7.0882e-5;         // rotation rate [rad/s]
    const.rho0_Mars  = 0.020e9;          // surface density [kg/km^3]
    const.H_Mars     = 11.1;             // scale height [km]

    // --- J2000 epoch ---
    const.J2000_JD = 2451545.0;           // Julian Date of J2000.0

    // --- Indexed arrays (planet 1=Mercury .. 6=Saturn) ---
    const.mu_planets = [const.mu_Mercury, const.mu_Venus, const.mu_Earth, ..
                        const.mu_Mars, const.mu_Jupiter, const.mu_Saturn];
    const.R_planets  = [const.R_Mercury, const.R_Venus, const.R_Earth, ..
                        const.R_Mars, const.R_Jupiter, const.R_Saturn];
    const.planet_names = ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn"];

    // --- Standard gravity ---
    const.g0 = 9.80665e-3;               // [km/s^2]

endfunction


function d = dot(a, b)
    d = sum(a .* b);
endfunction


function c = cross(a, b)
    c = [a(2)*b(3) - a(3)*b(2); ..
         a(3)*b(1) - a(1)*b(3); ..
         a(1)*b(2) - a(2)*b(1)];
endfunction
