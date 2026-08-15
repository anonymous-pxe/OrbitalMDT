// OrbitalMDT :: Mission Utilities
// Launch window analysis, orbital lifetime, eclipse analysis, vis-viva, SOI.

function result = synodic_period(T1, T2)
    // Synodic period between two orbiting bodies.
    T_syn = abs(T1 * T2 / (T1 - T2));

    result.T1             = T1;
    result.T2             = T2;
    result.T_synodic      = T_syn;
    result.T_synodic_days = T_syn / 86400;
    result.T_synodic_years = T_syn / (365.25 * 86400);
endfunction


function result = launch_window_analysis(dep_planet, arr_planet, start_year, n_windows)
    // Estimate launch windows from synodic period.

    const = orbital_constants();

    a_planets = [0.387, 0.723, 1.000, 1.524, 5.203, 9.537];

    T_dep = 2 * %pi * sqrt((a_planets(dep_planet) * const.AU)^3 / const.mu_Sun);
    T_arr = 2 * %pi * sqrt((a_planets(arr_planet) * const.AU)^3 / const.mu_Sun);

    syn = synodic_period(T_dep, T_arr);

    JD_start = date_to_jd(start_year, 1, 1);

    windows = zeros(n_windows, 1);
    window_dates = list();

    for k = 0:(n_windows - 1)
        JD_window = JD_start + k * syn.T_synodic_days;
        windows(k + 1) = JD_window;

        [y, m, d] = jd_to_date(JD_window);
        wd.year  = y;
        wd.month = floor(m);
        wd.day   = floor(d);
        wd.JD    = JD_window;
        window_dates(k + 1) = wd;
    end

    result.dep_planet    = dep_planet;
    result.arr_planet    = arr_planet;
    result.synodic_period = syn;
    result.windows       = windows;
    result.window_dates  = window_dates;
    result.n_windows     = n_windows;
endfunction


function result = orbital_lifetime(a, e, m, Cd, A, mu, rho0, H, R_planet)
    // Estimate orbital lifetime due to atmospheric drag.
    // INPUTS:
    //   a        semi-major axis [km]
    //   e        eccentricity
    //   m        spacecraft mass [kg]
    //   Cd       drag coefficient (~2.2)
    //   A        cross-sectional area [m^2]
    //   mu       gravitational parameter [km^3/s^2]
    //   rho0     surface density [kg/km^3]
    //   H        scale height [km]
    //   R_planet planet radius [km]

    r_peri = a * (1 - e);
    h_peri = r_peri - R_planet;
    rho_peri = rho0 * exp(-h_peri / H);

    A_km2 = A * 1e-6;
    beta = m / (Cd * A_km2);

    T = 2 * %pi * sqrt(a^3 / mu);

    // averaged decay rate (simplified, low-e approximation)
    da_dt = -2 * %pi * rho_peri * a^2 / beta;

    if abs(da_dt) > 1e-20 then
        delta_a = a - (R_planet + 80);
        lifetime_sec = abs(delta_a / da_dt);
    else
        lifetime_sec = %inf;
    end

    result.a              = a;
    result.e              = e;
    result.h_perigee      = h_peri;
    result.rho_perigee    = rho_peri;
    result.beta           = beta;
    result.da_dt          = da_dt;
    result.lifetime_sec   = lifetime_sec;
    result.lifetime_days  = lifetime_sec / 86400;
    result.lifetime_years = lifetime_sec / (365.25 * 86400);
endfunction


function result = eclipse_analysis(a, e, i, R_planet, R_sun_dist)
    // Eclipse fraction estimate for an orbit (cylindrical shadow, Earth).

    const = orbital_constants();
    mu = const.mu_Earth;
    T = 2 * %pi * sqrt(a^3 / mu);

    rho = asin(min(1, R_planet / a));

    eclipse_fraction = rho / %pi;
    t_eclipse = eclipse_fraction * T;
    t_sunlit  = T - t_eclipse;

    result.a                = a;
    result.T_period         = T;
    result.T_period_min     = T / 60;
    result.eclipse_fraction = eclipse_fraction;
    result.t_eclipse        = t_eclipse;
    result.t_eclipse_min    = t_eclipse / 60;
    result.t_sunlit         = t_sunlit;
    result.t_sunlit_min     = t_sunlit / 60;
    result.shadow_angle     = rho * 180 / %pi;
endfunction


function result = vis_viva(r, a, mu)
    // Vis-viva equation: velocity at radius r in orbit with SMA a.
    v = sqrt(mu * (2/r - 1/a));
    result.v      = v;
    result.energy = -mu / (2*a);
    result.r      = r;
    result.a      = a;
endfunction


function result = sphere_of_influence(a_planet, m_planet, m_sun)
    // Sphere of influence radius.
    // m_planet, m_sun are mu values used as mass ratio proxy.
    r_soi = a_planet * (m_planet / m_sun)^(2/5);
    result.r_soi    = r_soi;
    result.r_soi_AU = r_soi / 149597870.7;
    result.a_planet = a_planet;
endfunction
