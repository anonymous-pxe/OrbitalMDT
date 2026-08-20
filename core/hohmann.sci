// OrbitalMDT :: Hohmann Transfer Calculator
// Two-impulse minimum-energy coplanar orbit transfer between circular orbits.

function result = hohmann_transfer(r1, r2, mu)
    // INPUTS:  r1 [km] initial orbit radius, r2 [km] final, mu [km^3/s^2]
    // OUTPUT:  result struct

    if r1 <= 0 | r2 <= 0 | mu <= 0 then
        error("hohmann_transfer: r1, r2, mu must be positive");
    end

    a_t = (r1 + r2) / 2;
    e_t = abs(r2 - r1) / (r2 + r1);

    v1_circ = sqrt(mu / r1);
    v2_circ = sqrt(mu / r2);

    v_t_peri = sqrt(mu * (2/min(r1,r2) - 1/a_t));
    v_t_apo  = sqrt(mu * (2/max(r1,r2) - 1/a_t));

    if r2 > r1 then
        dv1 = v_t_peri - v1_circ;
        dv2 = v2_circ - v_t_apo;
    else
        dv1 = v1_circ - v_t_apo;
        dv2 = v_t_peri - v2_circ;
    end

    dv_total   = abs(dv1) + abs(dv2);
    t_transfer = %pi * sqrt(a_t^3 / mu);

    omega_target = sqrt(mu / r2^3);
    alpha = %pi - omega_target * t_transfer;

    result.r1             = r1;
    result.r2             = r2;
    result.a_transfer     = a_t;
    result.e_transfer     = e_t;
    result.v1_circ        = v1_circ;
    result.v2_circ        = v2_circ;
    result.v_t_peri       = v_t_peri;
    result.v_t_apo        = v_t_apo;
    result.dv1            = abs(dv1);
    result.dv2            = abs(dv2);
    result.dv_total       = dv_total;
    result.t_transfer     = t_transfer;
    result.T_transfer     = 2 * %pi * sqrt(a_t^3 / mu);
    result.phase_angle    = alpha;
    result.phase_angle_deg = alpha * 180 / %pi;
    result.energy_transfer = -mu / (2 * a_t);  // Specific orbital energy [km^2/s^2]
    result.dv1_sq         = (abs(dv1))^2;
endfunction


function result = hohmann_with_parking(r_park, r_target, mu_central, mu_depart, R_depart)
    // Hohmann from parking orbit, accounting for hyperbolic departure.
    // INPUTS:
    //   r_park     parking orbit radius [km]
    //   r_target   target orbit radius around central body [km]
    //   mu_central central body mu [km^3/s^2]
    //   mu_depart  departure body mu [km^3/s^2]
    //   R_depart   departure body orbit radius around central body [km]

    h = hohmann_transfer(R_depart, r_target, mu_central);

    v_inf  = h.dv1;
    v_park = sqrt(mu_depart / r_park);
    v_hyp  = sqrt(v_inf^2 + 2 * mu_depart / r_park);

    dv_departure = v_hyp - v_park;

    result = h;
    result.v_inf_departure     = v_inf;
    result.v_park              = v_park;
    result.v_hyperbolic        = v_hyp;
    result.dv_departure_actual = dv_departure;
    result.C3                  = v_inf^2;
endfunction
