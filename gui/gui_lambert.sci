// OrbitalMDT :: Lambert Solver Tab

function build_lambert_tab(fig)

    y_base = 25;
    x_panel = 15;
    pw = 280;

    uicontrol(fig, 'style', 'text', 'string', '[*] LAMBERT PROBLEM SOLVER', ..
        'position', [x_panel, y_base+660, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.8, 0.4, 0.1], 'tag', 'content_lb_title');

    uicontrol(fig, 'style', 'text', 'string', 'Input Mode:', ..
        'position', [x_panel, y_base+632, 100, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_lb_mode_lbl');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Position Vectors (km)|Orbital Elements|Planet-to-Planet', ..
        'position', [x_panel+100, y_base+630, 175, 25], 'fontsize', 10, ..
        'tag', 'content_lb_mode');

    // position vector 1
    uicontrol(fig, 'style', 'text', 'string', '-- Position 1 (km) --', ..
        'position', [x_panel, y_base+600, pw, 20], 'fontsize', 10, ..
        'fontweight', 'bold', 'horizontalalignment', 'center', ..
        'foreground', [0.4, 0.4, 0.6], 'tag', 'content_lb_lbl1');

    uicontrol(fig, 'style', 'text', 'string', 'x1:', ..
        'position', [x_panel, y_base+575, 30, 20], 'fontsize', 10, 'tag', 'content_lb_lbl_x1');
    uicontrol(fig, 'style', 'edit', 'string', '5000', ..
        'position', [x_panel+30, y_base+573, 60, 25], 'fontsize', 10, 'tag', 'content_lb_r1x');

    uicontrol(fig, 'style', 'text', 'string', 'y1:', ..
        'position', [x_panel+95, y_base+575, 30, 20], 'fontsize', 10, 'tag', 'content_lb_lbl_y1');
    uicontrol(fig, 'style', 'edit', 'string', '10000', ..
        'position', [x_panel+125, y_base+573, 60, 25], 'fontsize', 10, 'tag', 'content_lb_r1y');

    uicontrol(fig, 'style', 'text', 'string', 'z1:', ..
        'position', [x_panel+190, y_base+575, 30, 20], 'fontsize', 10, 'tag', 'content_lb_lbl_z1');
    uicontrol(fig, 'style', 'edit', 'string', '2100', ..
        'position', [x_panel+220, y_base+573, 60, 25], 'fontsize', 10, 'tag', 'content_lb_r1z');

    // position vector 2
    uicontrol(fig, 'style', 'text', 'string', '-- Position 2 (km) --', ..
        'position', [x_panel, y_base+545, pw, 20], 'fontsize', 10, ..
        'fontweight', 'bold', 'horizontalalignment', 'center', ..
        'foreground', [0.4, 0.4, 0.6], 'tag', 'content_lb_lbl2');

    uicontrol(fig, 'style', 'text', 'string', 'x2:', ..
        'position', [x_panel, y_base+520, 30, 20], 'fontsize', 10, 'tag', 'content_lb_lbl_x2');
    uicontrol(fig, 'style', 'edit', 'string', '-14600', ..
        'position', [x_panel+30, y_base+518, 60, 25], 'fontsize', 10, 'tag', 'content_lb_r2x');

    uicontrol(fig, 'style', 'text', 'string', 'y2:', ..
        'position', [x_panel+95, y_base+520, 30, 20], 'fontsize', 10, 'tag', 'content_lb_lbl_y2');
    uicontrol(fig, 'style', 'edit', 'string', '2500', ..
        'position', [x_panel+125, y_base+518, 60, 25], 'fontsize', 10, 'tag', 'content_lb_r2y');

    uicontrol(fig, 'style', 'text', 'string', 'z2:', ..
        'position', [x_panel+190, y_base+520, 30, 20], 'fontsize', 10, 'tag', 'content_lb_lbl_z2');
    uicontrol(fig, 'style', 'edit', 'string', '7000', ..
        'position', [x_panel+220, y_base+518, 60, 25], 'fontsize', 10, 'tag', 'content_lb_r2z');

    // time of flight
    uicontrol(fig, 'style', 'text', 'string', 'Time of Flight:', ..
        'position', [x_panel, y_base+485, 130, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_lb_lbl3');
    uicontrol(fig, 'style', 'edit', 'string', '3600', ..
        'position', [x_panel+130, y_base+483, 80, 25], 'fontsize', 10, ..
        'tag', 'content_lb_tof');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'seconds|minutes|hours|days', ..
        'position', [x_panel+215, y_base+483, 65, 25], 'fontsize', 9, ..
        'value', 1, 'tag', 'content_lb_tof_unit');

    // central body
    uicontrol(fig, 'style', 'text', 'string', 'Central Body:', ..
        'position', [x_panel, y_base+453, 130, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_lb_lbl4');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Earth (mu=398600)|Sun (mu=1.327e11)|Mars (mu=42828)|Moon (mu=4905)|Custom', ..
        'position', [x_panel+130, y_base+451, 145, 25], 'fontsize', 10, ..
        'tag', 'content_lb_body');

    // direction
    uicontrol(fig, 'style', 'text', 'string', 'Direction:', ..
        'position', [x_panel, y_base+423, 130, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_lb_lbl5');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Prograde (Short)|Retrograde (Long)', ..
        'position', [x_panel+130, y_base+421, 145, 25], 'fontsize', 10, ..
        'tag', 'content_lb_direction');

    // solve button
    uicontrol(fig, 'style', 'pushbutton', 'string', 'SOLVE LAMBERT PROBLEM', ..
        'position', [x_panel, y_base+375, pw, 35], ..
        'fontsize', 12, 'fontweight', 'bold', ..
        'background', [0.8, 0.4, 0.1], 'foreground', [1, 1, 1], ..
        'callback', 'cb_solve_lambert()', 'tag', 'content_lb_solve');

    // results
    uicontrol(fig, 'style', 'text', 'string', '[*] SOLUTION', ..
        'position', [x_panel, y_base+345, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.8, 0.3, 0.0], 'tag', 'content_lb_res_title');

    rl = ['v1 = [--, --, --] km/s  '; ..
          '|v1| = -- km/s         '; ..
          'v2 = [--, --, --] km/s  '; ..
          '|v2| = -- km/s         '; ..
          'Semi-major axis: -- km  '; ..
          'Eccentricity: --        '; ..
          'Inclination: -- deg     '; ..
          'Transfer angle: -- deg  '; ..
          'Status: Awaiting input  '];

    for k = 1:9
        uicontrol(fig, 'style', 'text', 'string', rl(k,:), ..
            'position', [x_panel, y_base+345-k*23, pw, 20], ..
            'fontsize', 9, 'horizontalalignment', 'left', ..
            'fontname', 'Consolas', 'tag', 'content_lb_result_' + string(k));
    end

    uicontrol(fig, 'style', 'text', ..
        'string', 'Transfer orbit will be plotted here', ..
        'position', [310, y_base+300, 870, 40], 'fontsize', 14, ..
        'horizontalalignment', 'center', 'foreground', [0.5, 0.5, 0.6], ..
        'tag', 'content_lb_plot_placeholder');
endfunction


function cb_solve_lambert()

    const = orbital_constants();

    r1x = strtod(get(findobj('tag', 'content_lb_r1x'), 'string'));
    r1y = strtod(get(findobj('tag', 'content_lb_r1y'), 'string'));
    r1z = strtod(get(findobj('tag', 'content_lb_r1z'), 'string'));

    r2x = strtod(get(findobj('tag', 'content_lb_r2x'), 'string'));
    r2y = strtod(get(findobj('tag', 'content_lb_r2y'), 'string'));
    r2z = strtod(get(findobj('tag', 'content_lb_r2z'), 'string'));

    r1_vec = [r1x; r1y; r1z];
    r2_vec = [r2x; r2y; r2z];

    tof_val = strtod(get(findobj('tag', 'content_lb_tof'), 'string'));
    tof_unit = get(findobj('tag', 'content_lb_tof_unit'), 'value');
    select tof_unit
    case 1, dt = tof_val;
    case 2, dt = tof_val * 60;
    case 3, dt = tof_val * 3600;
    case 4, dt = tof_val * 86400;
    end

    body = get(findobj('tag', 'content_lb_body'), 'value');
    select body
    case 1, mu = const.mu_Earth;
    case 2, mu = const.mu_Sun;
    case 3, mu = const.mu_Mars;
    case 4, mu = const.mu_Moon;
    case 5, mu = const.mu_Earth;
    end

    dir_val = get(findobj('tag', 'content_lb_direction'), 'value');
    if dir_val == 1 then direction = 1; else direction = -1; end

    [v1, v2, converged] = lambert_solver(r1_vec, r2_vec, dt, mu, direction);

    if converged then
        [a, e, i_rad, RAAN, omega, nu] = state_to_orbital_elements(r1_vec, v1, mu);

        cos_dnu = dot(r1_vec, r2_vec) / (norm(r1_vec) * norm(r2_vec));
        dnu = acos(max(-1, min(1, cos_dnu))) * 180 / %pi;

        set(findobj('tag', 'content_lb_result_1'), 'string', ..
            msprintf('v1=[%.3f, %.3f, %.3f]', v1(1), v1(2), v1(3)));
        set(findobj('tag', 'content_lb_result_2'), 'string', ..
            msprintf('|v1| = %.4f km/s', norm(v1)));
        set(findobj('tag', 'content_lb_result_3'), 'string', ..
            msprintf('v2=[%.3f, %.3f, %.3f]', v2(1), v2(2), v2(3)));
        set(findobj('tag', 'content_lb_result_4'), 'string', ..
            msprintf('|v2| = %.4f km/s', norm(v2)));
        set(findobj('tag', 'content_lb_result_5'), 'string', ..
            msprintf('Semi-major axis: %.2f km', a));
        set(findobj('tag', 'content_lb_result_6'), 'string', ..
            msprintf('Eccentricity:    %.6f', e));
        set(findobj('tag', 'content_lb_result_7'), 'string', ..
            msprintf('Inclination:     %.3f deg', i_rad*180/%pi));
        set(findobj('tag', 'content_lb_result_8'), 'string', ..
            msprintf('Transfer angle:  %.2f deg', dnu));
        set(findobj('tag', 'content_lb_result_9'), 'string', ..
            '[OK] Status: CONVERGED');

        ph = findobj('tag', 'content_lb_plot_placeholder');
        if ph <> [] then set(ph, 'visible', 'off'); end
        plot_lambert_transfer(r1_vec, r2_vec, v1, v2, mu, dt);

        update_status(msprintf('Lambert solved! |v1|=%.4f km/s, SMA=%.1f km', norm(v1), a));
    else
        set(findobj('tag', 'content_lb_result_9'), 'string', ..
            '[NO] Status: DID NOT CONVERGE');
        update_status('Lambert solver did not converge. Try different parameters.');
    end
endfunction


function plot_lambert_transfer(r1, r2, v1, v2, mu, dt)

    newaxes();
    a = gca();
    a.axes_bounds = [0.28, 0.05, 0.70, 0.90];

    try
        [t_tmp, states] = propagate_orbit(r1, v1, [0, dt], mu);

        param3d(states(1,:), states(2,:), states(3,:));
        e_c = gce();
        e_c.foreground = color(0, 150, 255);
        e_c.thickness = 2;

        param3d([r1(1)], [r1(2)], [r1(3)]);
        e_p = gce(); e_p.mark_mode = 'on'; e_p.mark_style = 9; e_p.mark_size = 2;
        e_p.mark_foreground = color(0, 200, 0);

        param3d([r2(1)], [r2(2)], [r2(3)]);
        e_p = gce(); e_p.mark_mode = 'on'; e_p.mark_style = 5; e_p.mark_size = 2;
        e_p.mark_foreground = color(255, 0, 0);

        param3d([0], [0], [0]);
        e_p = gce(); e_p.mark_mode = 'on'; e_p.mark_style = 9; e_p.mark_size = 3;
        e_p.mark_foreground = color(255, 200, 0);
    catch
        param3d([r1(1), r2(1)], [r1(2), r2(2)], [r1(3), r2(3)]);
    end

    title('Lambert Transfer Orbit (3D)');
    xlabel('X [km]');
    ylabel('Y [km]');
    zlabel('Z [km]');
endfunction
