// OrbitalMDT :: Atmospheric Re-entry Analysis
// Simplified ballistic entry with exponential atmosphere model.
// Allen-Eggers analytical estimates + trajectory integration.
// This is a preliminary model — not suitable for flight operations.

function result = ballistic_entry(v_entry, gamma_entry, h_entry, beta, R_nose, planet)
    // INPUTS:
    //   v_entry     entry velocity [km/s]
    //   gamma_entry entry flight path angle [degrees] (negative = descending)
    //   h_entry     entry altitude [km]
    //   beta        ballistic coefficient [kg/km^2] (m / (Cd * A))
    //   R_nose      nose radius [m]
    //   planet      "Earth" or "Mars"
    // OUTPUT:
    //   result struct

    select planet
    case "Earth"
        R_p  = 6371.0;
        rho0 = 1.225e9;
        H    = 8.5;
        g0   = 9.80665e-3;
    case "Mars"
        R_p  = 3389.5;
        rho0 = 0.020e9;
        H    = 11.1;
        g0   = 3.711e-3;
    else
        R_p  = 6371.0;
        rho0 = 1.225e9;
        H    = 8.5;
        g0   = 9.80665e-3;
    end

    gamma_rad = gamma_entry * %pi / 180;
    sin_gamma = abs(sin(gamma_rad));

    if sin_gamma < 1e-10 then sin_gamma = 1e-10; end

    // --- Allen-Eggers analytical estimates ---
    h_peak_decel = H * log(rho0 * H / (beta * sin_gamma));
    rho_peak = rho0 * exp(-h_peak_decel / H);
    a_peak = v_entry^2 * sin_gamma * rho_peak / (2 * beta);
    g_loading = a_peak / g0;
    v_peak_decel = v_entry * exp(-0.5);

    // --- Heating (Sutton-Graves) ---
    rho_peak_kgm3 = rho_peak * 1e-9;
    v_peak_ms = v_peak_decel * 1000;

    k_sg = 1.7415e-4;
    if planet == "Mars" then k_sg = 1.9e-4; end

    q_peak = k_sg * sqrt(rho_peak_kgm3 / R_nose) * v_peak_ms^3;
    q_peak_kw = q_peak * 10;
    Q_total = v_entry^2 * 1e6 / (2 * sqrt(g0 * 1000 * sin_gamma));

    // --- Trajectory integration (altitude-stepping) ---
    n_pts = 200;
    h_traj = linspace(h_entry, 0, n_pts);
    v_traj = zeros(1, n_pts);
    a_traj = zeros(1, n_pts);
    q_traj = zeros(1, n_pts);

    v_traj(1) = v_entry;

    for k = 2:n_pts
        dh = abs(h_traj(k-1) - h_traj(k));
        rho_k = rho0 * exp(-h_traj(k) / H);

        a_k = v_traj(k-1)^2 * rho_k / (2 * beta);
        a_traj(k) = a_k;

        // velocity decrement: dv = -(drag deceleration) * ds/v
        // ds = dh / sin|gamma|,  so delta_v = -a_k * dh / (v * sin|gamma|)
        if v_traj(k-1) > 1e-6 then
            delta_v = a_k * dh / (v_traj(k-1) * sin_gamma);
            v_traj(k) = max(v_traj(k-1) - delta_v, 1e-6);
        else
            v_traj(k) = 1e-6;
        end

        rho_kgm3 = rho_k * 1e-9;
        v_ms = v_traj(k) * 1000;
        q_traj(k) = k_sg * sqrt(rho_kgm3 / R_nose) * v_ms^3 * 10;
    end

    // --- Dynamic Pressure (q = 0.5 * rho * v^2) [kPa] ---
    rho_kgm3_all = rho0 * exp(-h_traj / H) * 1e-9;
    v_ms_all = v_traj * 1000;
    dyn_press_traj = 0.5 * rho_kgm3_all .* (v_ms_all.^2) / 1000; // kPa
    peak_dyn_press = max(dyn_press_traj);

    result.v_entry        = v_entry;
    result.gamma_entry    = gamma_entry;
    result.h_entry        = h_entry;
    result.beta           = beta;
    result.planet         = planet;
    result.h_peak_decel   = h_peak_decel;
    result.v_peak_decel   = v_peak_decel;
    result.a_peak         = a_peak;
    result.g_loading      = g_loading;
    result.q_peak         = q_peak_kw;
    result.Q_total        = Q_total;
    result.peak_dyn_press = peak_dyn_press; // kPa
    result.h_traj         = h_traj;
    result.v_traj         = v_traj;
    result.a_traj         = a_traj;
    result.q_traj         = q_traj;
    result.dyn_press_traj = dyn_press_traj;
    result.disclaimer     = "Preliminary ballistic re-entry model - engineering estimate only.";
endfunction


function print_entry_summary(result)
    mprintf("\n===== ATMOSPHERIC ENTRY ANALYSIS =====\n");
    mprintf("  Planet:              %s\n", result.planet);
    mprintf("  Entry velocity:      %.3f km/s (%.0f m/s)\n", result.v_entry, result.v_entry*1000);
    mprintf("  Entry angle:         %.1f deg\n", result.gamma_entry);
    mprintf("  Entry altitude:      %.0f km\n", result.h_entry);
    mprintf("  ---- Peak Conditions ----\n");
    mprintf("  Peak decel altitude: %.1f km\n", result.h_peak_decel);
    mprintf("  Peak deceleration:   %.1f g\n", result.g_loading);
    mprintf("  Velocity at peak:    %.3f km/s\n", result.v_peak_decel);
    mprintf("  Peak heat flux:      %.1f kW/m^2\n", result.q_peak);
    mprintf("=======================================\n");
endfunction
