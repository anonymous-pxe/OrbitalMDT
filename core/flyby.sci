// OrbitalMDT :: Gravity Assist / Planetary Flyby Calculator
// Unpowered and powered flybys using patched-conic hyperbolic model.
// All input/output vectors are heliocentric ecliptic J2000 unless noted.

function result = gravity_assist(v_inf_in, v_planet, mu_planet, r_periapsis, R_planet)
    // Unpowered gravity assist.
    // INPUTS:
    //   v_inf_in    incoming v-infinity vector relative to planet [km/s] (3x1)
    //   v_planet    planet heliocentric velocity [km/s] (3x1)
    //   mu_planet   planet mu [km^3/s^2]
    //   r_periapsis closest approach from planet center [km]
    //   R_planet    planet radius [km]
    // OUTPUT:
    //   result struct

    v_inf = norm(v_inf_in);
    altitude = r_periapsis - R_planet;

    if altitude < 0 then
        result.valid = %F;
        result.error = "Periapsis below planet surface";
        return;
    end

    if v_inf < 1e-10 then
        result.valid = %F;
        result.error = "V-infinity too small";
        return;
    end

    // hyperbolic eccentricity and turn angle
    ecc_hyp = 1 + r_periapsis * v_inf^2 / mu_planet;
    delta = 2 * asin(1 / ecc_hyp);

    a_hyp = -mu_planet / v_inf^2;
    b = abs(a_hyp) * sqrt(ecc_hyp^2 - 1);
    v_periapsis = sqrt(v_inf^2 + 2 * mu_planet / r_periapsis);

    // rotate v_inf_in by delta using Rodrigues formula
    v_inf_unit = v_inf_in / v_inf;

    // flyby plane normal: v_inf x v_planet
    n = cross(v_inf_in, v_planet);
    n_mag = norm(n);
    if n_mag > 1e-10 then
        n = n / n_mag;
    else
        // colinear case: pick arbitrary perpendicular
        if abs(v_inf_unit(1)) < 0.9 then
            perp = [1; 0; 0];
        else
            perp = [0; 1; 0];
        end
        n = cross(v_inf_unit, perp);
        n = n / norm(n);
    end

    // Rodrigues rotation of v_inf_in by angle delta around n
    cd = cos(delta); sd = sin(delta);
    v_inf_out_dir = v_inf_unit * cd + cross(n, v_inf_unit) * sd ..
                    + n * dot(n, v_inf_unit) * (1 - cd);
    v_inf_out = v_inf * v_inf_out_dir;

    v_sc_in  = v_inf_in + v_planet;
    v_sc_out = v_inf_out + v_planet;
    dv_helio = 2 * v_inf * sin(delta / 2);

    result.valid           = %T;
    result.v_inf_in        = v_inf_in;
    result.v_inf_out       = v_inf_out;
    result.v_inf_mag       = v_inf;
    result.turn_angle      = delta;
    result.turn_angle_deg  = delta * 180 / %pi;
    result.eccentricity    = ecc_hyp;
    result.a_hyperbola     = a_hyp;
    result.impact_param    = b;
    result.r_periapsis     = r_periapsis;
    result.altitude        = altitude;
    result.v_periapsis     = v_periapsis;
    result.v_helio_in      = v_sc_in;
    result.v_helio_out     = v_sc_out;
    result.v_helio_in_mag  = norm(v_sc_in);
    result.v_helio_out_mag = norm(v_sc_out);
    result.dv_helio        = dv_helio;
    result.delta_v_helio   = norm(v_sc_out) - norm(v_sc_in);
endfunction


function result = powered_flyby(v_inf_in, v_planet, mu_planet, r_periapsis, R_planet, dv_burn)
    // Powered gravity assist (prograde burn at periapsis).
    // dv_burn [km/s] applied at periapsis in the velocity direction.

    v_inf = norm(v_inf_in);

    v_peri_before = sqrt(v_inf^2 + 2 * mu_planet / r_periapsis);
    v_peri_after  = v_peri_before + dv_burn;

    if v_peri_after^2 < 2 * mu_planet / r_periapsis then
        v_inf_out_mag = 0;
    else
        v_inf_out_mag = sqrt(v_peri_after^2 - 2 * mu_planet / r_periapsis);
    end

    ecc_in  = 1 + r_periapsis * v_inf^2 / mu_planet;
    if v_inf_out_mag > 1e-10 then
        ecc_out = 1 + r_periapsis * v_inf_out_mag^2 / mu_planet;
    else
        ecc_out = 1;
    end

    delta_in  = asin(min(1, 1 / ecc_in));
    delta_out = asin(min(1, 1 / ecc_out));
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
    result.dv_gain        = v_inf_out_mag - v_inf;
endfunction
