// OrbitalMDT :: Reference Frame Transformations
// Conversions between fundamental astronomical coordinate systems.
// Supported frames:
// - Ecliptic J2000 (Heliocentric/Geocentric ecliptic frame)
// - Equatorial J2000 (Earth mean equator and equinox of J2000.0)
// - Heliocentric ↔ Planetocentric (Body-centered relative vectors)

function vec_eq = ecliptic_to_equatorial(vec_ecl, eps_rad)
    // Rotate 3D vector or 3xN matrix from Ecliptic J2000 to Equatorial J2000.
    // INPUTS:
    //   vec_ecl - 3x1 or 3xN matrix [km or km/s] in Ecliptic J2000
    //   eps_rad - Obliquity of ecliptic [rad] (optional, defaults to J2000 value 23.4392911 deg)
    // OUTPUT:
    //   vec_eq  - 3x1 or 3xN matrix in Equatorial J2000

    if ~exists('eps_rad', 'local') then
        const = orbital_constants();
        eps_rad = const.eps_J2000 * const.deg2rad;
    end

    c = cos(eps_rad);
    s = sin(eps_rad);

    R_ecl2eq = [1,  0,  0; ..
                0,  c, -s; ..
                0,  s,  c];

    vec_eq = R_ecl2eq * vec_ecl;
endfunction


function vec_ecl = equatorial_to_ecliptic(vec_eq, eps_rad)
    // Rotate 3D vector or 3xN matrix from Equatorial J2000 to Ecliptic J2000.
    // INPUTS:
    //   vec_eq  - 3x1 or 3xN matrix [km or km/s] in Equatorial J2000
    //   eps_rad - Obliquity of ecliptic [rad] (optional, defaults to J2000 value 23.4392911 deg)
    // OUTPUT:
    //   vec_ecl - 3x1 or 3xN matrix in Ecliptic J2000

    if ~exists('eps_rad', 'local') then
        const = orbital_constants();
        eps_rad = const.eps_J2000 * const.deg2rad;
    end

    c = cos(eps_rad);
    s = sin(eps_rad);

    R_eq2ecl = [1,  0,  0; ..
                0,  c,  s; ..
                0, -s,  c];

    vec_ecl = R_eq2ecl * vec_eq;
endfunction


function [r_pl_centric, v_pl_centric] = heliocentric_to_planetocentric(r_sc_helio, v_sc_helio, r_pl_helio, v_pl_helio)
    // Convert spacecraft heliocentric state to planet-centered state.
    // INPUTS:
    //   r_sc_helio, v_sc_helio - Spacecraft heliocentric position [km] and velocity [km/s]
    //   r_pl_helio, v_pl_helio - Planet heliocentric position [km] and velocity [km/s]
    // OUTPUTS:
    //   r_pl_centric, v_pl_centric - Planet-relative state vector

    r_pl_centric = r_sc_helio - r_pl_helio;
    v_pl_centric = v_sc_helio - v_pl_helio;
endfunction


function [r_sc_helio, v_sc_helio] = planetocentric_to_heliocentric(r_pl_centric, v_pl_centric, r_pl_helio, v_pl_helio)
    // Convert planet-centered spacecraft state to heliocentric state.
    // INPUTS:
    //   r_pl_centric, v_pl_centric - Planet-relative state vector [km, km/s]
    //   r_pl_helio, v_pl_helio     - Planet heliocentric position [km] and velocity [km/s]
    // OUTPUTS:
    //   r_sc_helio, v_sc_helio     - Spacecraft heliocentric state vector

    r_sc_helio = r_pl_centric + r_pl_helio;
    v_sc_helio = v_pl_centric + v_pl_helio;
endfunction
