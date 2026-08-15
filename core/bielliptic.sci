// OrbitalMDT :: Bi-Elliptic Transfer Calculator
// Three-impulse transfer. Can beat Hohmann when r_final/r_initial > 11.94.

function result = bielliptic_transfer(r1, r2, r_intermediate, mu)
    // INPUTS:
    //   r1             initial orbit radius [km]
    //   r2             final orbit radius [km]
    //   r_intermediate apoapsis of first transfer ellipse [km]
    //   mu             gravitational parameter [km^3/s^2]

    if r1 <= 0 | r2 <= 0 | r_intermediate <= 0 | mu <= 0 then
        error("bielliptic_transfer: all inputs must be positive");
    end
    if r_intermediate < max(r1, r2) then
        error("bielliptic_transfer: r_intermediate must be >= max(r1, r2)");
    end

    v1_circ = sqrt(mu / r1);
    v2_circ = sqrt(mu / r2);

    a1 = (r1 + r_intermediate) / 2;
    v_t1_peri = sqrt(mu * (2/r1 - 1/a1));
    v_t1_apo  = sqrt(mu * (2/r_intermediate - 1/a1));

    a2 = (r_intermediate + r2) / 2;
    v_t2_apo  = sqrt(mu * (2/r_intermediate - 1/a2));
    v_t2_peri = sqrt(mu * (2/r2 - 1/a2));

    dv1 = abs(v_t1_peri - v1_circ);
    dv2 = abs(v_t2_apo - v_t1_apo);
    dv3 = abs(v2_circ - v_t2_peri);
    dv_total = dv1 + dv2 + dv3;

    t1 = %pi * sqrt(a1^3 / mu);
    t2 = %pi * sqrt(a2^3 / mu);
    t_total = t1 + t2;

    hohmann_result = hohmann_transfer(r1, r2, mu);

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
