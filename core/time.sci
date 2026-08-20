// OrbitalMDT :: Time Utilities Module
// Centralized time conversion and date handling system.
// Supported time scales & formats: Calendar (Y, M, D, h, m, s), Julian Date (JD),
// Modified Julian Date (MJD), Julian Centuries relative to J2000.0 (T).

function JD = date_to_jd(year, month, day, hour, min, sec)
    // Convert calendar date to Julian Date (JD).
    // INPUTS:
    //   year   - full calendar year (e.g. 2026)
    //   month  - month (1-12)
    //   day    - day of month (1-31)
    //   hour   - hour (0-23, optional default 0)
    //   min    - minute (0-59, optional default 0)
    //   sec    - second (0-59, optional default 0)
    // OUTPUT:
    //   JD     - Julian Date [days]

    if ~exists('hour', 'local') then hour = 0; end
    if ~exists('min', 'local') then min = 0; end
    if ~exists('sec', 'local') then sec = 0; end

    y = year;
    m = month;
    if m <= 2 then
        y = y - 1;
        m = m + 12;
    end

    A = floor(y / 100);
    B = 2 - A + floor(A / 4);

    day_fraction = (hour + min / 60 + sec / 3600) / 24;

    JD = floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + day + day_fraction + B - 1524.5;
endfunction


function [year, month, day, hour, min, sec] = jd_to_date(JD)
    // Convert Julian Date (JD) to calendar date.
    // INPUT:
    //   JD    - Julian Date [days]
    // OUTPUTS:
    //   year, month, day, hour, min, sec

    Z = floor(JD + 0.5);
    F = (JD + 0.5) - Z;

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

    day_with_frac = B - D - floor(30.6001 * E) + F;
    day = floor(day_with_frac);

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

    frac = day_with_frac - day;
    total_sec = round(frac * 86400);
    hour = floor(total_sec / 3600);
    rem_sec = total_sec - hour * 3600;
    min = floor(rem_sec / 60);
    sec = rem_sec - min * 60;
endfunction


function T = jd_to_centuries_j2000(JD)
    // Calculate Julian Centuries past J2000.0 (JD 2451545.0).
    const = orbital_constants();
    T = (JD - const.J2000_JD) / 36525.0;
endfunction


function MJD = jd_to_mjd(JD)
    // Convert Julian Date (JD) to Modified Julian Date (MJD).
    MJD = JD - 2400000.5;
endfunction


function JD = mjd_to_jd(MJD)
    // Convert Modified Julian Date (MJD) to Julian Date (JD).
    JD = MJD + 2400000.5;
endfunction


function str = format_date_str(year, month, day)
    // Format year, month, day as YYYY-MM-DD string.
    str = msprintf("%04d-%02d-%02d", floor(year), floor(month), floor(day));
endfunction


function [year, month, day, ok, msg] = parse_date_str(date_str)
    // Parse date string (YYYY-MM-DD, YYYY/MM/DD, or YYYY MM DD) into numerical year, month, day.
    // Handles optional time component and validates calendar date bounds.
    ok = %T;
    msg = "";
    year = 2000; month = 1; day = 1;

    if ~exists('date_str', 'local') | isempty(date_str) | type(date_str) <> 10 then
        ok = %F; msg = "Date string is empty or invalid.";
        return;
    end

    // Normalize separators (- / , :) to spaces
    s = stripblanks(date_str);
    s = strsubst(s, "-", " ");
    s = strsubst(s, "/", " ");
    s = strsubst(s, ",", " ");

    toks = tokens(s);
    if size(toks, "*") < 3 then
        ok = %F; msg = "Invalid date format. Expected YYYY-MM-DD or YYYY MM DD.";
        return;
    end

    y_num = strtod(toks(1));
    m_num = strtod(toks(2));
    d_num = strtod(toks(3));

    if isnan(y_num) | isnan(m_num) | isnan(d_num) then
        ok = %F; msg = "Date contains non-numeric characters.";
        return;
    end

    year  = floor(y_num);
    month = floor(m_num);
    day   = floor(d_num);

    // Validate month
    if month < 1 | month > 12 then
        ok = %F; msg = msprintf("Month %d is invalid (must be 1-12).", month);
        return;
    end

    // Validate days in month (accounting for leap years)
    days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    is_leap = ((modulo(year, 4) == 0 & modulo(year, 100) <> 0) | modulo(year, 400) == 0);
    if is_leap then days_in_month(2) = 29; end

    if day < 1 | day > days_in_month(month) then
        ok = %F; msg = msprintf("Day %d is invalid for month %d, year %d (max %d days).", day, month, year, days_in_month(month));
        return;
    end

    if year < 1800 | year > 2200 then
        ok = %F; msg = msprintf("Year %d is out of supported ephemeris domain (1800-2200).", year);
        return;
    end
endfunction

