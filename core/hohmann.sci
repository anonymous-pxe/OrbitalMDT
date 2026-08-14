// ============================================================================
// OrbitalMDT — Hohmann Transfer Calculator
// ============================================================================
// Classical two-impulse minimum-energy coplanar orbit transfer.
// ============================================================================

function result = hohmann_transfer(r1, r2, mu)
    // Compute Hohmann transfer between two circular orbits
    // INPUTS:
    //   r1 - Radius of initial orbit [km]
    //   r2 - Radius of final orbit [km]
    //   mu - Gravitational parameter [km^3/s^2]
    // OUTPUT:
    //   result - struct with all transfer parameters
    
    // Transfer orbit semi-major axis
    a_t = (r1 + r2) / 2;
    
    // Eccentricity of transfer orbit
    e_t = abs(r2 - r1) / (r2 + r1);
    
    // Velocities on circular orbits
    v1_circ = sqrt(mu / r1);
    v2_circ = sqrt(mu / r2);
    
    // Velocities on transfer orbit at periapsis and apoapsis
    v_t_peri = sqrt(mu * (2/r1 - 1/a_t));
    v_t_apo  = sqrt(mu * (2/r2 - 1/a_t));
    
    // Delta-V for each burn
    if r2 > r1 then
        // Transfer to higher orbit
        dv1 = v_t_peri - v1_circ;   // Burn at periapsis (accelerate)
        dv2 = v2_circ - v_t_apo;    // Burn at apoapsis (accelerate)
    else
        // Transfer to lower orbit
        dv1 = v1_circ - v_t_peri;   // Burn at apoapsis (decelerate)
        dv2 = v_t_apo - v2_circ;    // Burn at periapsis (decelerate)
    end
    
    dv_total = abs(dv1) + abs(dv2);
    
    // Transfer time (half period of transfer ellipse)
    t_transfer = %pi * sqrt(a_t^3 / mu);
    
    // Transfer orbit period (full)
    T_transfer = 2 * %pi * sqrt(a_t^3 / mu);
    
    // Phase angle for rendezvous (if transferring between planet orbits)
    // Angular velocity of target
    omega_target = sqrt(mu / r2^3);
    alpha = %pi - omega_target * t_transfer;  // Required phase angle [rad]
    
    // Store results
    result.r1         = r1;
    result.r2         = r2;
    result.a_transfer = a_t;
    result.e_transfer = e_t;
    result.v1_circ    = v1_circ;
    result.v2_circ    = v2_circ;
    result.v_t_peri   = v_t_peri;
    result.v_t_apo    = v_t_apo;
    result.dv1        = abs(dv1);
    result.dv2        = abs(dv2);
    result.dv_total   = dv_total;
    result.t_transfer = t_transfer;
    result.T_transfer = T_transfer;
    result.phase_angle = alpha;
    result.phase_angle_deg = alpha * 180 / %pi;
    
    // Energy parameters
    result.C3_departure = (abs(dv1))^2;  // Characteristic energy [km^2/s^2]
    result.energy_transfer = -mu / (2 * a_t);
    
endfunction


function result = hohmann_with_parking(r_park, r_target, mu_central, mu_depart, R_depart)
    // Hohmann transfer from a parking orbit around departure body
    // to target orbit, accounting for hyperbolic departure
    // INPUTS:
    //   r_park     - Parking orbit radius around departure body [km]
    //   r_target   - Target orbit radius around central body [km] (e.g., Mars orbit radius around Sun)
    //   mu_central - Central body mu (e.g., mu_Sun) [km^3/s^2]
    //   mu_depart  - Departure body mu (e.g., mu_Earth) [km^3/s^2]
    //   R_depart   - Departure body orbit radius around central body [km]
    // OUTPUT:
    //   result - struct with transfer parameters
    
    // First get the basic Hohmann transfer
    h = hohmann_transfer(R_depart, r_target, mu_central);
    
    // Hyperbolic excess velocity at departure
    v_inf = h.dv1;  // This is v_infinity for departure
    
    // Velocity on parking orbit
    v_park = sqrt(mu_depart / r_park);
    
    // Velocity at periapsis of departure hyperbola
    v_hyp = sqrt(v_inf^2 + 2 * mu_depart / r_park);
    
    // Actual delta-V needed (burn from parking orbit)
    dv_departure = v_hyp - v_park;
    
    // Store
    result = h;
    result.v_inf_departure = v_inf;
    result.v_park          = v_park;
    result.v_hyperbolic    = v_hyp;
    result.dv_departure_actual = dv_departure;
    result.C3              = v_inf^2;
    
endfunction
