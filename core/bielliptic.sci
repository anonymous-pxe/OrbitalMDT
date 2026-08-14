// ============================================================================
// OrbitalMDT — Bi-Elliptic Transfer Calculator
// ============================================================================
// Three-impulse transfer that can be more efficient than Hohmann
// when the ratio r_final/r_initial > 11.94
// ============================================================================

function result = bielliptic_transfer(r1, r2, r_intermediate, mu)
    // Compute bi-elliptic transfer between two circular orbits
    // INPUTS:
    //   r1             - Radius of initial orbit [km]
    //   r2             - Radius of final orbit [km]
    //   r_intermediate - Radius of intermediate apoapsis [km] (must be > max(r1,r2))
    //   mu             - Gravitational parameter [km^3/s^2]
    // OUTPUT:
    //   result - struct with all transfer parameters
    
    // Circular velocities
    v1_circ = sqrt(mu / r1);
    v2_circ = sqrt(mu / r2);
    
    // First transfer ellipse: r1 → r_intermediate
    a1 = (r1 + r_intermediate) / 2;
    v_t1_peri = sqrt(mu * (2/r1 - 1/a1));
    v_t1_apo  = sqrt(mu * (2/r_intermediate - 1/a1));
    
    // Second transfer ellipse: r_intermediate → r2
    a2 = (r_intermediate + r2) / 2;
    v_t2_apo  = sqrt(mu * (2/r_intermediate - 1/a2));
    v_t2_peri = sqrt(mu * (2/r2 - 1/a2));
    
    // Three burns
    dv1 = abs(v_t1_peri - v1_circ);           // First burn: enter first transfer
    dv2 = abs(v_t2_apo - v_t1_apo);           // Second burn: at intermediate point
    dv3 = abs(v2_circ - v_t2_peri);           // Third burn: circularize at target
    
    dv_total = dv1 + dv2 + dv3;
    
    // Transfer times
    t1 = %pi * sqrt(a1^3 / mu);  // Half-period of first ellipse
    t2 = %pi * sqrt(a2^3 / mu);  // Half-period of second ellipse
    t_total = t1 + t2;
    
    // Compare with Hohmann
    hohmann_result = hohmann_transfer(r1, r2, mu);
    
    // Store results
    result.r1             = r1;
    result.r2             = r2;
    result.r_intermediate = r_intermediate;
    result.a1             = a1;
    result.a2             = a2;
    result.dv1            = dv1;
    result.dv2            = dv2;
    result.dv3            = dv3;
    result.dv_total       = dv_total;
    result.t1             = t1;
    result.t2             = t2;
    result.t_total        = t_total;
    result.dv_hohmann     = hohmann_result.dv_total;
    result.dv_savings     = hohmann_result.dv_total - dv_total;
    result.ratio          = r2 / r1;
    result.is_better      = (dv_total < hohmann_result.dv_total);
    
endfunction
