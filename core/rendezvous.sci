// OrbitalMDT :: Rendezvous & Phasing Maneuver Calculator
// Phasing orbits for co-orbital rendezvous and Hohmann-based coplanar rendezvous.

function result = phasing_maneuver(r_target, phase_angle, n_revs, mu)
    // Phasing maneuver to close a phase angle gap.
    // INPUTS:
    //   r_target    target circular orbit radius [km]
    //   phase_angle current phase angle [degrees] (positive = chaser behind)
    //   n_revs      number of phasing orbits (integer >= 1)
    //   mu          gravitational parameter [km^3/s^2]

    phi = phase_angle * %pi / 180;

    T_target = 2 * %pi * sqrt(r_target^3 / mu);
    omega_target = 2 * %pi / T_target;
    t_phase = phi / omega_target;

    // phasing orbit period so chaser gains (or loses) the angle
    T_phasing = T_target - t_phase / n_revs;

    a_phasing = (mu * (T_phasing / (2*%pi))^2)^(1/3);

    if a_phasing < r_target then
        r_peri = 2 * a_phasing - r_target;
        r_apo  = r_target;
    else
        r_peri = r_target;
        r_apo  = 2 * a_phasing - r_target;
    end
    e_phasing = (r_apo - r_peri) / (r_apo + r_peri);

    v_target = sqrt(mu / r_target);
    v_phasing_peri = sqrt(mu * (2/r_target - 1/a_phasing));

    dv1 = abs(v_phasing_peri - v_target);
    dv2 = dv1;
    dv_total = dv1 + dv2;
    t_total = n_revs * T_phasing;

    result.r_target      = r_target;
    result.phase_angle   = phase_angle;
    result.n_revs        = n_revs;
    result.T_target      = T_target;
    result.T_phasing     = T_phasing;
    result.a_phasing     = a_phasing;
    result.e_phasing     = e_phasing;
    result.r_perigee     = min(r_peri, r_apo);
    result.r_apogee      = max(r_peri, r_apo);
    result.v_target      = v_target;
    result.dv1           = dv1;
    result.dv2           = dv2;
    result.dv_total      = dv_total;
    result.t_total       = t_total;
    result.t_total_hours = t_total / 3600;
endfunction


function result = coplanar_rendezvous(r_chaser, r_target, phase_angle, mu)
    // Coplanar rendezvous via Hohmann + wait-for-phase.

    h = hohmann_transfer(r_chaser, r_target, mu);

    omega_target = sqrt(mu / r_target^3);
    omega_chaser = sqrt(mu / r_chaser^3);

    phi_transfer = %pi - omega_target * h.t_transfer;
    phi_current  = phase_angle * %pi / 180;

    d_omega = omega_chaser - omega_target;
    if abs(d_omega) > 1e-15 then
        t_wait = (phi_transfer - phi_current) / d_omega;
        if t_wait < 0 then
            t_wait = t_wait + 2*%pi / abs(d_omega);
        end
    else
        t_wait = 0;
    end

    result.hohmann       = h;
    result.phi_transfer  = phi_transfer * 180 / %pi;
    result.t_wait        = t_wait;
    result.t_wait_hours  = t_wait / 3600;
    result.t_total       = t_wait + h.t_transfer;
    result.dv_total      = h.dv_total;
endfunction
