// OrbitalMDT :: Centralized Time System
// Calendar <-> Julian Date conversions, epoch utilities.
// All dates are UT1. Time scale: TDB approximated as UT1 (sufficient for
// preliminary mission design with mean-element ephemeris).

function JD = date_to_jd(year, month, day, hour)
    // Calendar date -> Julian Date.
    // hour is optional decimal UT hours (default 0).

    if ~exists('hour', 'local') then hour = 0; end

    if month <= 2 then
        year  = year - 1;
        month = month + 12;
    end

    A  = floor(year / 100);
    B  = 2 - A + floor(A / 4);
    JD = floor(365.25 * (year + 4716)) + floor(30.6001 * (month + 1)) ..
         + day + hour / 24.0 + B - 1524.5;
endfunction


function [year, month, day] = jd_to_date(JD)
    // Julian Date -> calendar year, month, day (day is real-valued).

    JD_half = JD + 0.5;
    Z = floor(JD_half);
    F = JD_half - Z;

    if Z < 2299161 then
        A = Z;
    else
        alpha = floor((Z - 1867216.25) / 36524.25);
        A = Z + 1 + alpha - floor(alpha / 4);
    end

    B = A + 1524;
    C = floor((B - 122.1) / 365.25);
    D = floor(365.25 * C);
    E = floor((B - D) / 30.6001);

    day = B - D - floor(30.6001 * E) + F;

    if E < 14 then
        month = E - 1;
    else
        month = E - 13;
    end

    if month > 2 then
        year = C - 4716;
    else
        year = C - 4715;
    end
endfunction


function T = jd_to_centuries_j2000(JD)
    // Julian centuries since J2000.0 (used by ephemeris).
    T = (JD - 2451545.0) / 36525.0;
endfunction


function MJD = jd_to_mjd(JD)
    // Julian Date -> Modified Julian Date.
    MJD = JD - 2400000.5;
endfunction


function JD = mjd_to_jd(MJD)
    // Modified Julian Date -> Julian Date.
    JD = MJD + 2400000.5;
endfunction


function d = jd_days_since_j2000(JD)
    // Days elapsed since J2000.0 epoch.
    d = JD - 2451545.0;
endfunction
