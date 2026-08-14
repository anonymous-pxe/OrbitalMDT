// ============================================================================
// OrbitalMDT — Physical & Astronomical Constants
// ============================================================================
// All constants used across the toolkit. Single source of truth.
// Units: km, kg, seconds unless otherwise noted.
// ============================================================================

function const = orbital_constants()
    // ---- Universal Constants ----
    const.G = 6.67430e-20;              // Gravitational constant [km^3 / (kg * s^2)]
    
    // ---- Solar System Gravitational Parameters (mu = G*M) [km^3/s^2] ----
    const.mu_Sun     = 1.32712440018e11;
    const.mu_Mercury = 2.2032e4;
    const.mu_Venus   = 3.24859e5;
    const.mu_Earth   = 3.986004418e5;
    const.mu_Mars    = 4.282837e4;
    const.mu_Jupiter = 1.26686534e8;
    const.mu_Saturn  = 3.7931187e7;
    const.mu_Moon    = 4.9048695e3;
    
    // ---- Planetary Radii [km] ----
    const.R_Sun     = 695700;
    const.R_Mercury = 2439.7;
    const.R_Venus   = 6051.8;
    const.R_Earth   = 6371.0;
    const.R_Mars    = 3389.5;
    const.R_Jupiter = 69911;
    const.R_Saturn  = 58232;
    const.R_Moon    = 1737.4;
    
    // ---- Mean Orbital Radii (semi-major axes) [km] ----
    const.a_Mercury = 57.909e6;
    const.a_Venus   = 108.21e6;
    const.a_Earth   = 149.598e6;
    const.a_Mars    = 227.956e6;
    const.a_Jupiter = 778.570e6;
    const.a_Saturn  = 1433.53e6;
    
    // ---- Unit Conversions ----
    const.AU        = 149597870.7;       // 1 AU in km
    const.deg2rad   = %pi / 180;
    const.rad2deg   = 180 / %pi;
    const.day2sec   = 86400;             // seconds per day
    const.year2sec  = 365.25 * 86400;    // seconds per Julian year
    const.hr2sec    = 3600;
    
    // ---- Earth-Specific ----
    const.J2_Earth  = 1.08263e-3;        // Earth J2 oblateness coefficient
    const.Re_Earth  = 6378.137;          // Earth equatorial radius [km]
    const.Rp_Earth  = 6356.752;          // Earth polar radius [km]
    const.omega_Earth = 7.2921159e-5;    // Earth rotation rate [rad/s]
    const.rho0_Earth = 1.225e9;          // Sea-level air density [kg/km^3]
    const.H_Earth   = 8.5;              // Atmospheric scale height [km]
    
    // ---- Mars-Specific ----
    const.J2_Mars   = 1.9555e-3;
    const.omega_Mars = 7.0882e-5;        // Mars rotation rate [rad/s]
    const.rho0_Mars = 0.020e9;           // Mars surface density [kg/km^3]
    const.H_Mars    = 11.1;              // Mars scale height [km]
    
    // ---- J2000 Epoch ----
    const.J2000_JD  = 2451545.0;         // Julian Date of J2000.0 epoch
    
    // ---- Planetary mu array (indexed by planet number 1-6) ----
    const.mu_planets = [const.mu_Mercury, const.mu_Venus, const.mu_Earth, ...
                        const.mu_Mars, const.mu_Jupiter, const.mu_Saturn];
    const.R_planets  = [const.R_Mercury, const.R_Venus, const.R_Earth, ...
                        const.R_Mars, const.R_Jupiter, const.R_Saturn];
    const.planet_names = ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn"];
    
    // ---- Standard Gravitational Parameters for Atmosphere Models ----
    const.g0 = 9.80665e-3;              // Standard gravity [km/s^2]
    
endfunction
