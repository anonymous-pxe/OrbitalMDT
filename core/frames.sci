// OrbitalMDT :: Reference Frame Transformations
// Ecliptic J2000 <-> Equatorial J2000, heliocentric <-> planet-centered.
// Obliquity: mean obliquity of J2000.0 = 23.439291 deg (IAU 2006).

function r_eq = ecliptic_to_equatorial(r_ecl)
    // Ecliptic J2000 -> Equatorial J2000 (3x1 vector).
    eps = 23.439291 * %pi / 180;
    ce = cos(eps);
    se = sin(eps);
    R = [1, 0, 0; 0, ce, -se; 0, se, ce];
    r_eq = R * r_ecl;
endfunction


function r_ecl = equatorial_to_ecliptic(r_eq)
    // Equatorial J2000 -> Ecliptic J2000 (3x1 vector).
    eps = 23.439291 * %pi / 180;
    ce = cos(eps);
    se = sin(eps);
    R = [1, 0, 0; 0, ce, se; 0, -se, ce];
    r_ecl = R * r_eq;
endfunction


function [r_pc, v_pc] = heliocentric_to_planetcentric(r_sc, v_sc, r_planet, v_planet)
    // Convert heliocentric state to planet-centered state.
    // All vectors in the same frame (ecliptic J2000).
    // INPUTS:
    //   r_sc, v_sc         spacecraft heliocentric position/velocity [km, km/s]
    //   r_planet, v_planet  planet heliocentric position/velocity [km, km/s]
    // OUTPUTS:
    //   r_pc, v_pc          planet-centered position/velocity [km, km/s]
    r_pc = r_sc - r_planet;
    v_pc = v_sc - v_planet;
endfunction
