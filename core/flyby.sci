// ============================================================================
// OrbitalMDT — Gravity Assist / Planetary Flyby Calculator
// ============================================================================
// Computes velocity changes from unpowered and powered gravity assists.
// Used for missions like Voyager, Cassini, Juno.
// ============================================================================

function result = gravity_assist(v_inf_in, v_planet, mu_planet, r_periapsis, R_planet)
    // Compute gravity assist (unpowered flyby)
    // INPUTS:
    //   v_inf_in    - Incoming v-infinity vector relative to planet [km/s] (3x1)
    //   v_planet    - Planet velocity vector [km/s] (3x1)
    //   mu_planet   - Planet gravitational parameter [km^3/s^2]
    //   r_periapsis - Closest approach distance from planet center [km]
    //   R_planet    - Planet radius [km] (for altitude check)
    // OUTPUT:
    //   result - struct with flyby parameters
    
    v_inf = norm(v_inf_in);
    
    // Check if periapsis is above surface
    altitude = r_periapsis - R_planet;
    if altitude < 0 then
        result.valid = %F;
        result.error = "Periapsis below planet surface!";
        return;
    end
    
    // Turn angle (deflection angle)
    // delta = 2 * arcsin(1 / (1 + r_p * v_inf^2 / mu))
    ecc_hyp = 1 + r_periapsis * v_inf^2 / mu_planet;
    delta = 2 * asin(1 / ecc_hyp);
    
    // Semi-major axis of hyperbola (negative for hyperbolic)
    a_hyp = -mu_planet / v_inf^2;
    
    // Impact parameter (b)
    b = abs(a_hyp) * sqrt(ecc_hyp^2 - 1);
    
    // Velocity at periapsis
    v_periapsis = sqrt(v_inf^2 + 2 * mu_planet / r_periapsis);
    
    // Outgoing v-infinity (same magnitude, rotated by delta)
    // Rotate v_inf_in by delta in the flyby plane
    // For simplicity, compute the change in heliocentric velocity
    
    // Direction of turn: perpendicular to v_inf in the flyby plane
    // The flyby plane contains v_inf_in and the planet velocity
    
    // Outgoing v_inf in planet frame (rotated)
    // Simple 2D rotation for the magnitude change in heliocentric frame
    dv_helio = 2 * v_inf * sin(delta/2);
    
    // Bent velocity (rotate v_inf_in by delta angle)
    // Using Rodrigues rotation formula around the angular momentum direction
    v_inf_unit = v_inf_in / v_inf;
    
    // Normal to flyby plane (v_inf × v_planet defines plane)
    n = cross(v_inf_in, v_planet);
    if norm(n) > 1e-10 then
        n = n / norm(n);
    else
        n = [0; 0; 1];  // Default if colinear
    end
    
    // Rotate v_inf_in by delta around n (Rodrigues)
    v_inf_out_unit = v_inf_unit * cos(delta) + cross(n, v_inf_unit) * sin(delta) + ...
                     n * dot(n, v_inf_unit) * (1 - cos(delta));
    v_inf_out = v_inf * v_inf_out_unit;
    
    // Heliocentric velocities
    v_sc_in  = v_inf_in + v_planet;
    v_sc_out = v_inf_out + v_planet;
    
    // Store results
    result.valid         = %T;
    result.v_inf_in      = v_inf_in;
    result.v_inf_out     = v_inf_out;
    result.v_inf_mag     = v_inf;
    result.turn_angle    = delta;
    result.turn_angle_deg = delta * 180 / %pi;
    result.eccentricity  = ecc_hyp;
    result.a_hyperbola   = a_hyp;
    result.impact_param  = b;
    result.r_periapsis   = r_periapsis;
    result.altitude      = altitude;
    result.v_periapsis   = v_periapsis;
    result.v_helio_in    = v_sc_in;
    result.v_helio_out   = v_sc_out;
    result.v_helio_in_mag  = norm(v_sc_in);
    result.v_helio_out_mag = norm(v_sc_out);
    result.dv_helio      = dv_helio;
    result.delta_v_helio = norm(v_sc_out) - norm(v_sc_in);
    
endfunction


function result = powered_flyby(v_inf_in, v_planet, mu_planet, r_periapsis, R_planet, dv_burn)
    // Compute powered gravity assist (burn at periapsis)
    // INPUTS:
    //   Same as gravity_assist plus:
    //   dv_burn - Delta-V applied at periapsis [km/s] (prograde)
    // OUTPUT:
    //   result - struct with powered flyby parameters
    
    v_inf = norm(v_inf_in);
    
    // Velocity at periapsis (before burn)
    v_peri_before = sqrt(v_inf^2 + 2 * mu_planet / r_periapsis);
    
    // Velocity at periapsis after burn
    v_peri_after = v_peri_before + dv_burn;
    
    // New outgoing v-infinity
    v_inf_out_mag = sqrt(v_peri_after^2 - 2 * mu_planet / r_periapsis);
    
    // Turn angles for incoming and outgoing legs
    ecc_in  = 1 + r_periapsis * v_inf^2 / mu_planet;
    ecc_out = 1 + r_periapsis * v_inf_out_mag^2 / mu_planet;
    
    delta_in  = asin(1 / ecc_in);
    delta_out = asin(1 / ecc_out);
    total_turn = delta_in + delta_out;
    
    result.v_inf_in_mag   = v_inf;
    result.v_inf_out_mag  = v_inf_out_mag;
    result.v_peri_before  = v_peri_before;
    result.v_peri_after   = v_peri_after;
    result.dv_burn        = dv_burn;
    result.ecc_in         = ecc_in;
    result.ecc_out        = ecc_out;
    result.turn_angle_in  = delta_in * 180 / %pi;
    result.turn_angle_out = delta_out * 180 / %pi;
    result.total_turn     = total_turn * 180 / %pi;
    result.dv_gain        = v_inf_out_mag - v_inf;  // "Free" ΔV from powered flyby
    
endfunction
