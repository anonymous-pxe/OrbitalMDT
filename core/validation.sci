// OrbitalMDT :: Parameter Validation Engine
// Centralized boundary and domain validation functions.

function [ok, msg] = validate_positive_scalar(val, param_name)
    // Check if val is a strictly positive finite real scalar.
    ok = %T; msg = "";
    if size(val, "*") <> 1 | ~isreal(val) | isnan(val) | isinf(val) | val <= 0 then
        ok = %F;
        msg = param_name + " must be a positive finite real scalar value (> 0).";
    end
endfunction


function [ok, msg] = validate_nonnegative_scalar(val, param_name)
    // Check if val is a non-negative finite real scalar (>= 0).
    ok = %T; msg = "";
    if size(val, "*") <> 1 | ~isreal(val) | isnan(val) | isinf(val) | val < 0 then
        ok = %F;
        msg = param_name + " must be a non-negative finite real scalar (>= 0).";
    end
endfunction


function [ok, msg] = validate_bounded_scalar(val, param_name, min_val, max_val)
    // Check if val is a real scalar within [min_val, max_val].
    ok = %T; msg = "";
    if size(val, "*") <> 1 | ~isreal(val) | isnan(val) | isinf(val) | val < min_val | val > max_val then
        ok = %F;
        msg = msprintf("%s must be between %g and %g.", param_name, min_val, max_val);
    end
endfunction


function [num_val, ok, msg] = parse_numeric_input(str_input, param_name, min_val, max_val)
    // Safely parse a GUI string input to a numerical scalar and validate bounds.
    ok = %T; msg = ""; num_val = %nan;
    if ~exists('str_input', 'local') | isempty(str_input) then
        ok = %F; msg = param_name + " cannot be empty."; return;
    end

    s = stripblanks(string(str_input));
    if length(s) == 0 then
        ok = %F; msg = param_name + " cannot be empty."; return;
    end

    num_val = strtod(s);
    if size(num_val, "*") <> 1 | isnan(num_val) | isinf(num_val) then
        ok = %F; msg = param_name + " contains invalid non-numeric text."; return;
    end

    if exists('min_val', 'local') & exists('max_val', 'local') then
        if num_val < min_val | num_val > max_val then
            ok = %F; msg = msprintf("%s (value %g) must be between %g and %g.", param_name, num_val, min_val, max_val); return;
        end
    elseif exists('min_val', 'local') then
        if num_val < min_val then
            ok = %F; msg = msprintf("%s (value %g) must be >= %g.", param_name, num_val, min_val); return;
        end
    end
endfunction


function [ok, msg] = validate_vector_3d(vec, param_name)
    // Check if vec is a 3x1 or 1x3 real vector.
    ok = %T; msg = "";
    if size(vec, "*") <> 3 | ~isreal(vec) | or(isnan(vec)) | or(isinf(vec)) then
        ok = %F;
        msg = param_name + " must be a 3-element finite real vector.";
    end
endfunction


function [ok, msg] = validate_eccentricity(e)
    // Check if eccentricity e is non-negative and finite.
    ok = %T; msg = "";
    if size(e, "*") <> 1 | ~isreal(e) | isnan(e) | isinf(e) | e < 0 then
        ok = %F;
        msg = "Eccentricity e must be a non-negative real scalar (e >= 0).";
    end
endfunction


function [ok, msg] = validate_date_bounds(year, month, day)
    // Validate year, month (1-12), and day (1-31).
    ok = %T; msg = "";
    if year < 1800 | year > 2200 then
        ok = %F; msg = "Year out of recommended ephemeris range (1800-2200)."; return;
    end
    if month < 1 | month > 12 then
        ok = %F; msg = "Month must be between 1 and 12."; return;
    end
    if day < 1 | day > 31 then
        ok = %F; msg = "Day must be between 1 and 31."; return;
    end
endfunction


function [ok, msg] = validate_state_vector(r_vec, v_vec)
    // Check validity of position and velocity state vectors.
    [ok1, m1] = validate_vector_3d(r_vec, "Position vector r");
    if ~ok1 then ok = %F; msg = m1; return; end

    [ok2, m2] = validate_vector_3d(v_vec, "Velocity vector v");
    if ~ok2 then ok = %F; msg = m2; return; end

    if norm(r_vec) < 1e-3 then
        ok = %F; msg = "Position vector norm is zero or near-singular."; return;
    end
    ok = %T; msg = "";
endfunction

