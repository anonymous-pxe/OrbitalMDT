// OrbitalMDT :: Mission Planner Tab (Porkchop Plot)

function build_mission_planner_tab(fig)

    y_base = 25;
    x_panel = 15;
    pw = 280;

    uicontrol(fig, 'style', 'text', 'string', '[*] MISSION PARAMETERS', ..
        'position', [x_panel, y_base+660, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.2, 0.4, 0.8], 'tag', 'content_mp_title');

    // departure planet
    uicontrol(fig, 'style', 'text', 'string', 'Departure Planet:', ..
        'position', [x_panel, y_base+630, 130, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_mp_lbl1');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Mercury|Venus|Earth|Mars|Jupiter|Saturn', ..
        'position', [x_panel+135, y_base+628, 140, 25], 'fontsize', 10, ..
        'value', 3, 'tag', 'content_mp_dep_planet');

    // arrival planet
    uicontrol(fig, 'style', 'text', 'string', 'Arrival Planet:', ..
        'position', [x_panel, y_base+598, 130, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_mp_lbl2');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Mercury|Venus|Earth|Mars|Jupiter|Saturn', ..
        'position', [x_panel+135, y_base+596, 140, 25], 'fontsize', 10, ..
        'value', 4, 'tag', 'content_mp_arr_planet');

    // departure window
    uicontrol(fig, 'style', 'text', 'string', '-- Departure Window --', ..
        'position', [x_panel, y_base+565, pw, 20], 'fontsize', 10, ..
        'fontweight', 'bold', 'horizontalalignment', 'center', ..
        'foreground', [0.4, 0.4, 0.6], 'tag', 'content_mp_lbl3');

    uicontrol(fig, 'style', 'text', 'string', 'Start (YYYY MM DD):', ..
        'position', [x_panel, y_base+540, 140, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_mp_lbl4');
    uicontrol(fig, 'style', 'edit', 'string', '2028 5 1', ..
        'position', [x_panel+140, y_base+538, 135, 25], 'fontsize', 10, ..
        'tag', 'content_mp_dep_start');

    uicontrol(fig, 'style', 'text', 'string', 'End (YYYY MM DD):', ..
        'position', [x_panel, y_base+510, 140, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_mp_lbl5');
    uicontrol(fig, 'style', 'edit', 'string', '2028 11 30', ..
        'position', [x_panel+140, y_base+508, 135, 25], 'fontsize', 10, ..
        'tag', 'content_mp_dep_end');

    // arrival window
    uicontrol(fig, 'style', 'text', 'string', '-- Arrival Window --', ..
        'position', [x_panel, y_base+475, pw, 20], 'fontsize', 10, ..
        'fontweight', 'bold', 'horizontalalignment', 'center', ..
        'foreground', [0.4, 0.4, 0.6], 'tag', 'content_mp_lbl6');

    uicontrol(fig, 'style', 'text', 'string', 'Start (YYYY MM DD):', ..
        'position', [x_panel, y_base+450, 140, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_mp_lbl7');
    uicontrol(fig, 'style', 'edit', 'string', '2029 1 1', ..
        'position', [x_panel+140, y_base+448, 135, 25], 'fontsize', 10, ..
        'tag', 'content_mp_arr_start');

    uicontrol(fig, 'style', 'text', 'string', 'End (YYYY MM DD):', ..
        'position', [x_panel, y_base+420, 140, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_mp_lbl8');
    uicontrol(fig, 'style', 'edit', 'string', '2029 8 30', ..
        'position', [x_panel+140, y_base+418, 135, 25], 'fontsize', 10, ..
        'tag', 'content_mp_arr_end');

    // grid resolution
    uicontrol(fig, 'style', 'text', 'string', 'Grid Resolution:', ..
        'position', [x_panel, y_base+385, 140, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_mp_lbl9');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', '20x20 (Fast)|30x30 (Medium)|40x40 (Fine)|50x50 (High)', ..
        'position', [x_panel+135, y_base+383, 140, 25], 'fontsize', 10, ..
        'value', 2, 'tag', 'content_mp_resolution');

    // generate button
    uicontrol(fig, 'style', 'pushbutton', ..
        'string', 'GENERATE PORKCHOP PLOT', ..
        'position', [x_panel, y_base+340, pw, 35], ..
        'fontsize', 12, 'fontweight', 'bold', ..
        'background', [0.2, 0.5, 0.9], 'foreground', [1, 1, 1], ..
        'callback', 'cb_generate_porkchop()', ..
        'tag', 'content_mp_generate');

    // results
    uicontrol(fig, 'style', 'text', 'string', '[*] OPTIMAL WINDOW RESULTS', ..
        'position', [x_panel, y_base+305, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.1, 0.6, 0.2], 'tag', 'content_mp_res_title');

    init_res = ['Departure:     --'; ..
                'Arrival:       --'; ..
                'Delta-V Total: --'; ..
                'C3:            --'; ..
                'TOF:           --'; ..
                'Vinf Depart:   --'; ..
                'Vinf Arrive:   --'];

    for k = 1:7
        uicontrol(fig, 'style', 'text', 'string', init_res(k,:), ..
            'position', [x_panel, y_base+305-k*25, pw, 20], ..
            'fontsize', 10, 'horizontalalignment', 'left', ..
            'fontname', 'Consolas', ..
            'tag', 'content_mp_result_' + string(k));
    end

    // action buttons
    uicontrol(fig, 'style', 'pushbutton', 'string', 'Show Launch Windows', ..
        'position', [x_panel, y_base+100, pw/2-5, 30], 'fontsize', 10, ..
        'callback', 'cb_show_launch_windows()', 'tag', 'content_mp_windows');
    uicontrol(fig, 'style', 'pushbutton', 'string', 'Export Data', ..
        'position', [x_panel+pw/2+5, y_base+100, pw/2-5, 30], 'fontsize', 10, ..
        'callback', 'cb_export_porkchop()', 'tag', 'content_mp_export');

    // plot placeholder
    uicontrol(fig, 'style', 'text', ..
        'string', 'Porkchop Plot will appear here after generation', ..
        'position', [310, y_base+300, 870, 40], 'fontsize', 14, ..
        'horizontalalignment', 'center', 'foreground', [0.5, 0.5, 0.6], ..
        'tag', 'content_mp_plot_placeholder');
endfunction


function cb_generate_porkchop()

    update_status('Generating porkchop plot... This may take 30-60 seconds.');

    dep_id = get(findobj('tag', 'content_mp_dep_planet'), 'value');
    arr_id = get(findobj('tag', 'content_mp_arr_planet'), 'value');

    // parse dates using tokens() (handles extra whitespace safely)
    ds = strtod(tokens(get(findobj('tag', 'content_mp_dep_start'), 'string')));
    de = strtod(tokens(get(findobj('tag', 'content_mp_dep_end'),   'string')));
    as_tok = strtod(tokens(get(findobj('tag', 'content_mp_arr_start'), 'string')));
    ae = strtod(tokens(get(findobj('tag', 'content_mp_arr_end'),   'string')));

    dep_start_jd = date_to_jd(ds(1), ds(2), ds(3));
    dep_end_jd   = date_to_jd(de(1), de(2), de(3));
    arr_start_jd = date_to_jd(as_tok(1), as_tok(2), as_tok(3));
    arr_end_jd   = date_to_jd(ae(1), ae(2), ae(3));

    res_val = get(findobj('tag', 'content_mp_resolution'), 'value');
    res_map = [20, 30, 40, 50];
    n_grid = res_map(res_val);

    [dv_grid, c3_grid, tof_grid, dep_jd, arr_jd] = generate_porkchop( ..
        dep_id, arr_id, dep_start_jd, dep_end_jd, arr_start_jd, arr_end_jd, n_grid, n_grid);

    [opt_dep, opt_arr, opt_dv, opt_tof] = find_optimal_window(dv_grid, dep_jd, arr_jd);

    const = orbital_constants();
    dep_name = const.planet_names(dep_id);
    arr_name = const.planet_names(arr_id);

    [dy, dm, dd] = jd_to_date(opt_dep);
    dep_date_str = msprintf('%d-%02d-%02d', dy, floor(dm), floor(dd));
    [ay, am, ad] = jd_to_date(opt_arr);
    arr_date_str = msprintf('%d-%02d-%02d', ay, floor(am), floor(ad));

    // find C3 at optimal cell
    dv_temp = dv_grid;
    dv_temp(dv_temp == %inf) = 1e10;
    [mtmp, idx] = min(dv_temp);
    opt_c3 = c3_grid(idx(1), idx(2));
    vinf_dep = sqrt(max(opt_c3, 0));
    vinf_arr = max(opt_dv - vinf_dep, 0);

    set(findobj('tag', 'content_mp_result_1'), 'string', 'Departure:  ' + dep_date_str);
    set(findobj('tag', 'content_mp_result_2'), 'string', 'Arrival:    ' + arr_date_str);
    set(findobj('tag', 'content_mp_result_3'), 'string', msprintf('Delta-V Total: %.3f km/s', opt_dv));
    set(findobj('tag', 'content_mp_result_4'), 'string', msprintf('C3:          %.2f km^2/s^2', opt_c3));
    set(findobj('tag', 'content_mp_result_5'), 'string', msprintf('TOF:         %.0f days', opt_tof));
    set(findobj('tag', 'content_mp_result_6'), 'string', msprintf('Vinf Depart: %.3f km/s', vinf_dep));
    set(findobj('tag', 'content_mp_result_7'), 'string', msprintf('Vinf Arrive: %.3f km/s', vinf_arr));

    ph = findobj('tag', 'content_mp_plot_placeholder');
    if ph <> [] then set(ph, 'visible', 'off'); end

    newaxes();
    a = gca();
    a.axes_bounds = [0.28, 0.05, 0.70, 0.90];

    dep_days = dep_jd - dep_jd(1);
    arr_days = arr_jd - arr_jd(1);
    dv_plot = dv_grid;
    dv_plot(dv_plot == %inf) = %nan;

    valid = dv_plot(~isnan(dv_plot));
    if length(valid) > 0 then
        dv_min_val = min(valid);
        dv_max_val = min(max(valid), 25);
        levels = linspace(dv_min_val, dv_max_val, 20);
        contourf(dep_days, arr_days, dv_plot, levels);
        colorbar(min(levels), max(levels));
    end

    xlabel('Departure (days from ' + dep_date_str + ')');
    ylabel('Arrival (days from start)');
    title(dep_name + ' -> ' + arr_name + ' Porkchop Plot (Delta-V km/s)');

    plot(opt_dep - dep_jd(1), opt_arr - arr_jd(1), 'rp', 'MarkerSize', 14);

    update_status(msprintf('Porkchop complete! Optimal: %s -> %s, dV=%.3f km/s, TOF=%.0f d', ..
        dep_date_str, arr_date_str, opt_dv, opt_tof));
endfunction


function cb_show_launch_windows()

    dep_id = get(findobj('tag', 'content_mp_dep_planet'), 'value');
    arr_id = get(findobj('tag', 'content_mp_arr_planet'), 'value');

    result = launch_window_analysis(dep_id, arr_id, 2026, 8);
    const = orbital_constants();

    msg = msprintf('%s -> %s Launch Windows\n', const.planet_names(dep_id), const.planet_names(arr_id));
    msg = msg + msprintf('Synodic Period: %.1f days (%.2f years)\n\n', ..
        result.synodic_period.T_synodic_days, result.synodic_period.T_synodic_years);

    for k = 1:result.n_windows
        wd = result.window_dates(k);
        msg = msg + msprintf('Window %d: %d-%02d-%02d\n', k, wd.year, wd.month, wd.day);
    end

    messagebox(msg, 'Launch Windows', 'info');
endfunction


function cb_export_porkchop()
    messagebox('Export functionality: Save porkchop data to CSV file.', 'Export', 'info');
endfunction
