// ============================================================================
// OrbitalMDT — Atmospheric Re-entry Analysis
// ============================================================================
// Ballistic entry trajectory, peak heating, g-loading, and thermal analysis.
// Used for capsule design and EDL (Entry, Descent, Landing) planning.
// ============================================================================

function result = ballistic_entry(v_entry, gamma_entry, h_entry, beta, R_nose, planet)
    // Ballistic entry analysis (simplified exponential atmosphere)
    // INPUTS:
    //   v_entry   - Entry velocity [km/s]
    //   gamma_entry - Entry flight path angle [degrees] (negative = descending)
    //   h_entry   - Entry altitude [km]
    //   beta      - Ballistic coefficient [kg/km^2] (m / (Cd * A))
    //   R_nose    - Nose radius of vehicle [m] (for heating estimate)
    //   planet    - "Earth" or "Mars"
    // OUTPUT:
    //   result - struct with entry analysis
    
    // Planet parameters
    select planet
    case "Earth"
        R_p    = 6371.0;       // Planet radius [km]
        rho0   = 1.225e9;      // Sea level density [kg/km^3]
        H      = 8.5;          // Scale height [km]
        g0     = 9.80665e-3;   // Surface gravity [km/s^2]
    case "Mars"
        R_p    = 3389.5;
        rho0   = 0.020e9;
        H      = 11.1;
        g0     = 3.711e-3;
    else
        R_p    = 6371.0;
        rho0   = 1.225e9;
        H      = 8.5;
        g0     = 9.80665e-3;
    end
    
    gamma_rad = gamma_entry * %pi / 180;
    
    // ---- Analytical estimates (Allen-Eggers approximation) ----
    
    // Peak deceleration
    // a_max = v_entry^2 * sin(|gamma|) / (2 * e * H)  ... simplified
    // More precise:
    sin_gamma = abs(sin(gamma_rad));
    
    // Altitude of peak deceleration
    h_peak_decel = H * log(rho0 * H / (beta * sin_gamma));
    
    // Peak deceleration [km/s^2] → convert to g's
    rho_peak = rho0 * exp(-h_peak_decel / H);
    a_peak = v_entry^2 * sin_gamma * rho_peak / (2 * beta);
    g_loading = a_peak / g0;
    
    // Velocity at peak deceleration
    v_peak_decel = v_entry * exp(-1/2);  // ≈ 0.6065 * v_entry
    
    // ---- Heating estimates ----
    // Stagnation point heat flux (Sutton-Graves)
    // q_dot = k * sqrt(rho / R_nose) * v^3
    // k ≈ 1.7415e-4 for Earth (in W/cm^2 with rho in kg/m^3, R in m, v in m/s)
    
    // Convert units for heating calculation
    R_nose_km = R_nose / 1000;  // m to km
    
    // Peak stagnation heat flux [kW/m^2]
    // Using simplified correlation
    rho_peak_kgm3 = rho_peak * 1e-9;  // kg/km^3 to kg/m^3
    v_peak_ms = v_peak_decel * 1000;   // km/s to m/s
    
    k_sg = 1.7415e-4;  // Sutton-Graves constant for Earth
    if planet == "Mars" then k_sg = 1.9e-4; end
    
    q_peak = k_sg * sqrt(rho_peak_kgm3 / R_nose) * (v_peak_ms)^3;  // W/cm^2
    q_peak_kw = q_peak * 10;  // kW/m^2
    
    // Total heat load estimate [kJ/m^2]
    Q_total = v_entry^2 * 1e6 / (2 * sqrt(g0 * 1000 * sin_gamma));  // Simplified
    
    // ---- Trajectory integration (simplified) ----
    n_pts = 200;
    h_traj = linspace(h_entry, 0, n_pts);
    v_traj = zeros(1, n_pts);
    a_traj = zeros(1, n_pts);
    q_traj = zeros(1, n_pts);
    
    v_traj(1) = v_entry;
    
    for k = 2:n_pts
        dh = h_traj(k-1) - h_traj(k);
        rho_k = rho0 * exp(-h_traj(k) / H);
        
        // Deceleration at this altitude
        a_k = v_traj(k-1)^2 * rho_k / (2 * beta);
        a_traj(k) = a_k;
        
        // Velocity update (energy balance)
        dv = -a_k * dh / (v_traj(k-1) * sin_gamma);
        v_traj(k) = max(v_traj(k-1) + dv, 0.001);
        
        // Heat flux
        rho_kgm3 = rho_k * 1e-9;
        v_ms = v_traj(k) * 1000;
        q_traj(k) = k_sg * sqrt(rho_kgm3 / R_nose) * v_ms^3 * 10;  // kW/m^2
    end
    
    // Store results
    result.v_entry       = v_entry;
    result.gamma_entry   = gamma_entry;
    result.h_entry       = h_entry;
    result.beta          = beta;
    result.planet        = planet;
    result.h_peak_decel  = h_peak_decel;
    result.v_peak_decel  = v_peak_decel;
    result.a_peak        = a_peak;
    result.g_loading     = g_loading;
    result.q_peak        = q_peak_kw;
    result.Q_total       = Q_total;
    result.h_traj        = h_traj;
    result.v_traj        = v_traj;
    result.a_traj        = a_traj;
    result.q_traj        = q_traj;
    
endfunction


function print_entry_summary(result)
    // Pretty-print entry analysis results
    
    mprintf("\n===== ATMOSPHERIC ENTRY ANALYSIS =====\n");
    mprintf("  Planet:              %s\n", result.planet);
    mprintf("  Entry velocity:      %.3f km/s (%.0f m/s)\n", result.v_entry, result.v_entry*1000);
    mprintf("  Entry angle:         %.1f°\n", result.gamma_entry);
    mprintf("  Entry altitude:      %.0f km\n", result.h_entry);
    mprintf("  ---- Peak Conditions ----\n");
    mprintf("  Peak decel altitude: %.1f km\n", result.h_peak_decel);
    mprintf("  Peak deceleration:   %.1f g\n", result.g_loading);
    mprintf("  Velocity at peak:    %.3f km/s\n", result.v_peak_decel);
    mprintf("  Peak heat flux:      %.1f kW/m²\n", result.q_peak);
    mprintf("=======================================\n");
    
endfunction
