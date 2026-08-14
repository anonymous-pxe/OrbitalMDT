// ============================================================================
// OrbitalMDT — Mission Utilities
// ============================================================================
// Launch window analysis, orbital lifetime estimation, eclipse analysis,
// and other utility functions for mission planning.
// ============================================================================

function result = synodic_period(T1, T2)
    // Compute synodic period (time between successive alignments)
    // INPUTS:
    //   T1 - Orbital period of inner body [s]
    //   T2 - Orbital period of outer body [s]
    // OUTPUT:
    //   result - struct with synodic period
    
    T_syn = abs(T1 * T2 / (T1 - T2));
    
    result.T1 = T1;
    result.T2 = T2;
    result.T_synodic = T_syn;
    result.T_synodic_days = T_syn / 86400;
    result.T_synodic_years = T_syn / (365.25 * 86400);
    
endfunction


function result = launch_window_analysis(dep_planet, arr_planet, start_year, n_windows)
    // Estimate launch windows for interplanetary transfer
    // INPUTS:
    //   dep_planet - Departure planet ID (1-6)
    //   arr_planet - Arrival planet ID (1-6)
    //   start_year - Starting year to search
    //   n_windows  - Number of windows to find
    // OUTPUT:
    //   result - struct with window dates
    
    const = orbital_constants();
    
    // Get orbital periods
    a_dep = [0.387, 0.723, 1.000, 1.524, 5.203, 9.537];  // AU
    a_arr = a_dep;
    
    T_dep = 2 * %pi * sqrt((a_dep(dep_planet) * const.AU)^3 / const.mu_Sun);
    T_arr = 2 * %pi * sqrt((a_arr(arr_planet) * const.AU)^3 / const.mu_Sun);
    
    // Synodic period
    syn = synodic_period(T_dep, T_arr);
    
    // Starting Julian Date
    JD_start = date_to_jd(start_year, 1, 1);
    
    // Generate windows
    windows = zeros(n_windows, 1);
    window_dates = list();
    
    for k = 0:(n_windows-1)
        JD_window = JD_start + k * syn.T_synodic_days;
        windows(k+1) = JD_window;
        
        [y, m, d] = jd_to_date(JD_window);
        wd.year = y;
        wd.month = floor(m);
        wd.day = floor(d);
        wd.JD = JD_window;
        window_dates(k+1) = wd;
    end
    
    result.dep_planet = dep_planet;
    result.arr_planet = arr_planet;
    result.synodic_period = syn;
    result.windows = windows;
    result.window_dates = window_dates;
    result.n_windows = n_windows;
    
endfunction


function result = orbital_lifetime(a, e, m, Cd, A, mu, rho0, H, R_planet)
    // Estimate orbital lifetime due to atmospheric drag
    // INPUTS:
    //   a        - Semi-major axis [km]
    //   e        - Eccentricity
    //   m        - Spacecraft mass [kg]
    //   Cd       - Drag coefficient (~2.2 typical)
    //   A        - Cross-sectional area [m^2]
    //   mu       - Gravitational parameter [km^3/s^2]
    //   rho0     - Reference density at surface [kg/km^3]
    //   H        - Scale height [km]
    //   R_planet - Planet radius [km]
    // OUTPUT:
    //   result - struct with lifetime estimate
    
    // Perigee altitude and density
    r_peri = a * (1 - e);
    h_peri = r_peri - R_planet;
    rho_peri = rho0 * exp(-h_peri / H);
    
    // Ballistic coefficient [kg/km^2]
    A_km2 = A * 1e-6;  // m^2 to km^2
    beta = m / (Cd * A_km2);
    
    // Orbital period
    T = 2 * %pi * sqrt(a^3 / mu);
    
    // Semi-major axis decay rate (averaged over orbit)
    // da/dt ≈ -2*pi * rho_peri * a^2 / beta * I0(e*a/H)
    // Simplified for low eccentricity:
    da_dt = -2 * %pi * rho_peri * a^2 / beta;
    
    // Approximate lifetime
    if abs(da_dt) > 1e-20 then
        // Rough estimate: time for a to decrease to R_planet
        delta_a = a - (R_planet + 80);  // Until ~80 km (re-entry altitude)
        lifetime_sec = abs(delta_a / da_dt);
    else
        lifetime_sec = %inf;
    end
    
    result.a             = a;
    result.e             = e;
    result.h_perigee     = h_peri;
    result.rho_perigee   = rho_peri;
    result.beta          = beta;
    result.da_dt         = da_dt;
    result.lifetime_sec  = lifetime_sec;
    result.lifetime_days = lifetime_sec / 86400;
    result.lifetime_years = lifetime_sec / (365.25 * 86400);
    
endfunction


function result = eclipse_analysis(a, e, i, R_planet, R_sun_dist)
    // Estimate eclipse fraction for an orbit
    // INPUTS:
    //   a          - Semi-major axis [km]
    //   e          - Eccentricity
    //   i          - Inclination [rad]
    //   R_planet   - Planet radius [km]
    //   R_sun_dist - Distance from Sun [km] (for shadow cone)
    // OUTPUT:
    //   result - struct with eclipse parameters
    
    // Orbital period
    // For Earth orbit: mu_Earth
    const = orbital_constants();
    mu = const.mu_Earth;
    T = 2 * %pi * sqrt(a^3 / mu);
    
    // Shadow half-angle (cylindrical approximation)
    // sin(rho) = R_planet / a  (for circular orbit)
    rho = asin(R_planet / a);
    
    // Eclipse fraction (simplified for circular orbit, zero beta angle)
    eclipse_fraction = rho / %pi;
    
    // Eclipse duration
    t_eclipse = eclipse_fraction * T;
    
    // Sunlit duration
    t_sunlit = T - t_eclipse;
    
    // Beta angle effect (simplified)
    // If |beta| > rho, no eclipse
    // beta ≈ declination of Sun relative to orbit plane
    
    result.a               = a;
    result.T_period        = T;
    result.T_period_min    = T / 60;
    result.eclipse_fraction = eclipse_fraction;
    result.t_eclipse       = t_eclipse;
    result.t_eclipse_min   = t_eclipse / 60;
    result.t_sunlit        = t_sunlit;
    result.t_sunlit_min    = t_sunlit / 60;
    result.shadow_angle    = rho * 180 / %pi;
    
endfunction


function result = vis_viva(r, a, mu)
    // Vis-viva equation: compute velocity at any point in orbit
    // v^2 = mu * (2/r - 1/a)
    // INPUTS:
    //   r  - Current radius [km]
    //   a  - Semi-major axis [km]
    //   mu - Gravitational parameter [km^3/s^2]
    // OUTPUT:
    //   result - struct with velocity and energy
    
    v = sqrt(mu * (2/r - 1/a));
    energy = -mu / (2*a);
    
    result.v = v;
    result.energy = energy;
    result.r = r;
    result.a = a;
    
endfunction


function result = sphere_of_influence(a_planet, m_planet, m_sun)
    // Compute sphere of influence radius
    // r_SOI = a * (m_planet / m_sun)^(2/5)
    // INPUTS:
    //   a_planet - Planet semi-major axis [km]
    //   m_planet - Planet mu [km^3/s^2] (used as proxy for mass ratio)
    //   m_sun    - Sun mu [km^3/s^2]
    // OUTPUT:
    //   result - struct with SOI radius
    
    r_soi = a_planet * (m_planet / m_sun)^(2/5);
    
    result.r_soi = r_soi;
    result.r_soi_AU = r_soi / 149597870.7;
    result.a_planet = a_planet;
    
endfunction
