// ============================================================================
// OrbitalMDT — Rendezvous & Phasing Maneuver Calculator
// ============================================================================
// Computes phasing orbits for co-orbital rendezvous scenarios.
// Used for ISS docking, satellite servicing, and formation flying.
// ============================================================================

function result = phasing_maneuver(r_target, phase_angle, n_revs, mu)
    // Compute a phasing maneuver to close a phase angle gap
    // INPUTS:
    //   r_target    - Target circular orbit radius [km]
    //   phase_angle - Current phase angle between chaser and target [degrees]
    //                 (positive = chaser behind target)
    //   n_revs      - Number of phasing orbit revolutions (integer)
    //   mu          - Gravitational parameter [km^3/s^2]
    // OUTPUT:
    //   result - struct with phasing orbit parameters
    
    phi = phase_angle * %pi / 180;
    
    // Target orbital period
    T_target = 2 * %pi * sqrt(r_target^3 / mu);
    
    // Angular velocity of target
    omega_target = 2 * %pi / T_target;
    
    // Time for target to traverse the phase angle
    t_phase = phi / omega_target;
    
    // Required phasing orbit period
    // In n_revs, the chaser must cover (2*pi*n_revs + phase_angle)
    T_phasing = (T_target * n_revs - t_phase) / n_revs;
    
    // But we need the total time = n_revs * T_phasing = n_revs * T_target - t_phase
    // So T_phasing = T_target - t_phase/n_revs
    T_phasing = T_target - t_phase / n_revs;
    
    // Semi-major axis of phasing orbit
    a_phasing = (mu * (T_phasing / (2*%pi))^2)^(1/3);
    
    // Phasing orbit eccentricity and perigee/apogee
    if a_phasing < r_target then
        // Lower phasing orbit
        r_peri = 2 * a_phasing - r_target;
        r_apo  = r_target;
        e_phasing = (r_apo - r_peri) / (r_apo + r_peri);
    else
        // Higher phasing orbit
        r_peri = r_target;
        r_apo  = 2 * a_phasing - r_target;
        e_phasing = (r_apo - r_peri) / (r_apo + r_peri);
    end
    
    // Velocities
    v_target = sqrt(mu / r_target);  // Circular velocity at target orbit
    v_phasing_peri = sqrt(mu * (2/r_target - 1/a_phasing));
    
    // Delta-V for each burn
    dv1 = abs(v_phasing_peri - v_target);  // Enter phasing orbit
    dv2 = dv1;  // Return to circular (same magnitude)
    dv_total = dv1 + dv2;
    
    // Total time
    t_total = n_revs * T_phasing;
    
    // Store results
    result.r_target     = r_target;
    result.phase_angle  = phase_angle;
    result.n_revs       = n_revs;
    result.T_target     = T_target;
    result.T_phasing    = T_phasing;
    result.a_phasing    = a_phasing;
    result.e_phasing    = e_phasing;
    result.r_perigee    = min(r_peri, r_apo);
    result.r_apogee     = max(r_peri, r_apo);
    result.v_target     = v_target;
    result.dv1          = dv1;
    result.dv2          = dv2;
    result.dv_total     = dv_total;
    result.t_total      = t_total;
    result.t_total_hours = t_total / 3600;
    
endfunction


function result = coplanar_rendezvous(r_chaser, r_target, phase_angle, mu)
    // Compute coplanar rendezvous via Hohmann transfer
    // INPUTS:
    //   r_chaser    - Chaser circular orbit radius [km]
    //   r_target    - Target circular orbit radius [km]
    //   phase_angle - Phase angle [degrees]
    //   mu          - Gravitational parameter [km^3/s^2]
    // OUTPUT:
    //   result - struct with rendezvous parameters
    
    // Hohmann transfer
    h = hohmann_transfer(r_chaser, r_target, mu);
    
    // Wait time for proper phasing
    omega_target = sqrt(mu / r_target^3);
    omega_chaser = sqrt(mu / r_chaser^3);
    
    // Phase angle at which to initiate transfer
    phi_transfer = %pi - omega_target * h.t_transfer;
    phi_current = phase_angle * %pi / 180;
    
    // Time to wait
    d_omega = omega_chaser - omega_target;
    if abs(d_omega) > 1e-15 then
        t_wait = (phi_transfer - phi_current) / d_omega;
        if t_wait < 0 then
            t_wait = t_wait + 2*%pi / abs(d_omega);
        end
    else
        t_wait = 0;
    end
    
    result.hohmann      = h;
    result.phi_transfer = phi_transfer * 180 / %pi;
    result.t_wait       = t_wait;
    result.t_wait_hours = t_wait / 3600;
    result.t_total      = t_wait + h.t_transfer;
    result.dv_total     = h.dv_total;
    
endfunction
