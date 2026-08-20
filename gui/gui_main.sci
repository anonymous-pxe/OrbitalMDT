function ok = is_valid_handle(h)
    ok = %F;
    if exists('h', 'local') then
        if ~isempty(h) then
            try
                if size(h, "*") == 1 then
                    ok = is_handle_valid(h);
                else
                    ok = %F;
                end
            catch
                try
                    ok = (type(h) == 9);
                catch
                    ok = %F;
                end
            end
        end
    end
endfunction


function h = get_tag_obj(tag_str)
    h = findobj('tag', tag_str);
    if h <> [] then
        if size(h, "*") > 1 then h = h(1); end
    end
endfunction


function val = get_tag_val(tag_str, default_val)
    if ~exists('default_val', 'local') then default_val = 1; end
    val = default_val;
    h = get_tag_obj(tag_str);
    if is_valid_handle(h) then
        try
            val = h.value;
        catch
            try
                val = get(h, 'value');
            catch
            end
        end
    end
endfunction


function str = get_tag_str(tag_str, default_str)
    if ~exists('default_str', 'local') then default_str = ''; end
    str = default_str;
    h = get_tag_obj(tag_str);
    if is_valid_handle(h) then
        try
            str = h.string;
        catch
            try
                str = get(h, 'string');
            catch
            end
        end
    end
endfunction


function set_tag_str(tag_str, str_val)
    h = get_tag_obj(tag_str);
    if is_valid_handle(h) then
        try
            h.string = str_val;
        catch
            try
                set(h, 'string', str_val);
            catch
            end
        end
    end
endfunction


function [val, ok, msg] = gui_get_num(tag_str, field_name, min_val, max_val)
    // Retrieve and validate numeric value from a UI edit control.
    s = get_tag_str(tag_str, "");
    if exists('min_val', 'local') & exists('max_val', 'local') then
        [val, ok, msg] = parse_numeric_input(s, field_name, min_val, max_val);
    elseif exists('min_val', 'local') then
        [val, ok, msg] = parse_numeric_input(s, field_name, min_val);
    else
        [val, ok, msg] = parse_numeric_input(s, field_name);
    end
endfunction


function [val, ok, msg] = gui_get_positive_num(tag_str, field_name)
    // Retrieve and validate strictly positive (> 0) numeric value from UI edit control.
    s = get_tag_str(tag_str, "");
    [val, ok, msg] = parse_numeric_input(s, field_name);
    if ok then
        if val <= 0 then
            ok = %F;
            msg = field_name + " must be strictly positive (> 0).";
        end
    end
endfunction


function gui_report_error(msg)
    // Display error both in the GUI status bar and via a standard popup dialog.
    update_status("ERROR: " + msg);
    try
        messagebox(msg, "OrbitalMDT Input Error", "error");
    catch
    end
endfunction



function launch_orbital_mdt()

    // Launch the main OrbitalMDT application window.
    old_fig = findobj('tag', 'main_fig');
    if old_fig <> [] then
        for k = 1:size(old_fig, "*")
            try
                if is_valid_handle(old_fig(k)) then
                    delete(old_fig(k));
                end
            catch
            end
        end
    end

    // Detect screen resolution for responsive full-screen fit
    scr_w = 1920;
    scr_h = 1080;
    try
        scr = get(0, "screensize_px");
        if size(scr, "*") >= 4 then
            scr_w = scr(3);
            scr_h = scr(4);
        elseif size(scr, "*") >= 2 then
            scr_w = scr(1);
            scr_h = scr(2);
        end
    catch
    end

    // Use responsive usable screen area (bounded for optimal layout readability across 720p/1080p/4K)
    win_w = max(1100, min(scr_w - 40, 1920));
    win_h = max(720, min(scr_h - 90, 1080));
    pos_x = max(5, floor((scr_w - win_w) / 2));
    pos_y = max(25, floor((scr_h - win_h) / 2) - 10);

    fig = figure( ..
        'figure_name', 'OrbitalMDT -- Orbital Mechanics Mission Design Toolkit', ..
        'position', [pos_x, pos_y, win_w, win_h], ..
        'axes_size', [win_w, win_h], ..
        'tag', 'main_fig', ..
        'auto_resize', 'off', ..
        'menubar', 'none', ..
        'toolbar', 'none');

    // Configure clean neutral figure background and 64-color smooth jet colormap
    try
        fig.background = -2; // Clean white background
        try
            fig.color_map = jet(64);
        catch
            fig.color_map = jetcolormap(64);
        end
    catch
    end

    // --- Header Banner ---
    uicontrol(fig, ..
        'style', 'frame', ..
        'position', [0, win_h - 50, win_w, 50], ..
        'background', [0.1, 0.1, 0.2], ..
        'tag', 'title_banner');

    uicontrol(fig, ..
        'style', 'text', ..
        'string', '', ..
        'position', [0, win_h - 50, win_w, 45], ..
        'background', [0.1, 0.1, 0.2], ..
        'tag', 'title_text_bg');

    uicontrol(fig, ..
        'style', 'text', ..
        'string', '[OrbitalMDT] -- Mission Design Toolkit', ..
        'position', [15, win_h - 45, 600, 35], ..
        'fontsize', 16, ..
        'fontweight', 'bold', ..
        'horizontalalignment', 'left', ..
        'background', [0.1, 0.1, 0.2], ..
        'foreground', [0.9, 0.9, 1.0], ..
        'tag', 'title_text');

    uicontrol(fig, ..
        'style', 'text', ..
        'string', 'Professional Orbital Mechanics Analysis Suite', ..
        'position', [win_w - 585, win_h - 45, 570, 35], ..
        'fontsize', 11, ..
        'horizontalalignment', 'right', ..
        'background', [0.1, 0.1, 0.2], ..
        'foreground', [0.6, 0.6, 0.8], ..
        'tag', 'title_sub');

    // --- Tab buttons ---
    tab_names = ['Mission Planner', 'Transfers', 'Lambert Solver', ..
                 'Propagator', 'Solar System', 'Rocket Eq.', 'Re-Entry'];
    tab_colors = [
        0.2, 0.4, 0.8;
        0.2, 0.7, 0.3;
        0.8, 0.4, 0.1;
        0.6, 0.2, 0.8;
        0.8, 0.7, 0.1;
        0.8, 0.2, 0.2;
        0.2, 0.7, 0.7
    ];

    tab_gap = 6;
    tab_x0 = 15;
    tab_width = floor((win_w - 30 - 6 * tab_gap) / 7);
    tab_y = win_h - 90;

    for k = 1:7
        x_pos = tab_x0 + (k - 1) * (tab_width + tab_gap);
        btn = uicontrol(fig, ..
            'style', 'pushbutton', ..
            'string', tab_names(k), ..
            'position', [x_pos, tab_y, tab_width, 35], ..
            'fontsize', 11, ..
            'fontweight', 'bold', ..
            'tag', 'tab_btn_' + string(k), ..
            'callback', 'switch_tab(' + string(k) + ')');

        if k == 1 then
            try
                set(btn, 'background', tab_colors(k,:));
                set(btn, 'foreground', [1, 1, 1]);
            catch
                set(btn, 'backgroundcolor', tab_colors(k,:));
                set(btn, 'foregroundcolor', [1, 1, 1]);
            end
        else
            try
                set(btn, 'background', [0.85, 0.85, 0.85]);
                set(btn, 'foreground', [0.3, 0.3, 0.3]);
            catch
                set(btn, 'backgroundcolor', [0.85, 0.85, 0.85]);
                set(btn, 'foregroundcolor', [0.3, 0.3, 0.3]);
            end
        end
    end

    // --- Left Control Panel Background Frame ---
    uicontrol(fig, ..
        'style', 'frame', ..
        'position', [5, 25, 305, win_h - 120], ..
        'tag', 'panel_sidebar_frame', ..
        'background', [0.95, 0.95, 0.97]);

    // --- Status bar ---
    uicontrol(fig, ..
        'style', 'text', ..
        'string', ' Ready | Tab: Mission Planner', ..
        'position', [0, 0, win_w, 22], ..
        'fontsize', 9, ..
        'horizontalalignment', 'left', ..
        'background', [0.1, 0.1, 0.2], ..
        'foreground', [0.7, 0.7, 0.9], ..
        'tag', 'status_bar');

    try
        ud = struct('tab_colors', tab_colors, 'tab_names', tab_names, 'current_tab', 1);
        fig.user_data = ud;
    catch
    end

    build_mission_planner_tab(fig);
endfunction


function switch_tab(tab_id)
    fig = get_main_figure();
    if ~is_valid_handle(fig) then return; end

    tab_names = ['Mission Planner', 'Transfers', 'Lambert Solver', ..
                 'Propagator', 'Solar System', 'Rocket Eq.', 'Re-Entry'];
    tab_colors = [
        0.2, 0.4, 0.8;
        0.2, 0.7, 0.3;
        0.8, 0.4, 0.1;
        0.6, 0.2, 0.8;
        0.8, 0.7, 0.1;
        0.8, 0.2, 0.2;
        0.2, 0.7, 0.7
    ];

    for k = 1:7
        btn = findobj('tag', 'tab_btn_' + string(k));
        if is_valid_handle(btn) then
            try
                if k == tab_id then
                    set(btn, 'background', tab_colors(k,:));
                    set(btn, 'foreground', [1, 1, 1]);
                else
                    set(btn, 'background', [0.85, 0.85, 0.85]);
                    set(btn, 'foreground', [0.3, 0.3, 0.3]);
                end
            catch
                try
                    if k == tab_id then
                        set(btn, 'backgroundcolor', tab_colors(k,:));
                        set(btn, 'foregroundcolor', [1, 1, 1]);
                    else
                        set(btn, 'backgroundcolor', [0.85, 0.85, 0.85]);
                        set(btn, 'foregroundcolor', [0.3, 0.3, 0.3]);
                    end
                catch
                end
            end
        end
    end

    // 1. Delete all existing plot axes
    clear_plot_axes();

    // 2. Delete all content_ tagged UI controls
    // Iterate fig.children (includes uicontrols in Scilab 6.x)
    // and also use findobj as fallback for any orphans.
    try
        children = fig.children;
        for idx = size(children, "*"):-1:1
            try
                c = children(idx);
                if is_valid_handle(c) then
                    tg = "";
                    try tg = c.tag; catch end
                    if length(tg) >= 8 then
                        if part(tg, 1:8) == "content_" then
                            delete(c);
                        end
                    end
                end
            catch
            end
        end
    catch
    end

    // Fallback: also search globally for any content_ controls not caught above
    try
        stale = findobj("type", "uicontrol");
        if stale <> [] then
            for idx = size(stale, "*"):-1:1
                try
                    c = stale(idx);
                    if is_valid_handle(c) then
                        tg = "";
                        try tg = c.tag; catch end
                        if length(tg) >= 8 then
                            if part(tg, 1:8) == "content_" then
                                delete(c);
                            end
                        end
                    end
                catch
                end
            end
        end
    catch
    end

    status = findobj('tag', 'status_bar');
    if is_valid_handle(status) then
        try
            set(status, 'string', ' Ready | Tab: ' + tab_names(tab_id));
        catch
        end
    end

    select tab_id
    case 1, build_mission_planner_tab(fig);
    case 2, build_hohmann_tab(fig);
    case 3, build_lambert_tab(fig);
    case 4, build_propagator_tab(fig);
    case 5, build_solarsystem_tab(fig);
    case 6, build_rocket_tab(fig);
    case 7, build_reentry_tab(fig);
    end

    try
        fig.user_data.current_tab = tab_id;
    catch
    end
endfunction


function update_status(msg)
    status = findobj('tag', 'status_bar');
    if is_valid_handle(status) then
        try
            set(status, 'string', ' ' + msg);
        catch
        end
    end
endfunction


function clear_plot_axes()
    // Delete all existing Axes children from the main figure.
    // Prevents new plots from overlaying on previous ones.
    fig = get_main_figure();
    if ~is_valid_handle(fig) then return; end

    // Iterate fig.children in reverse (Axes are part of figure children hierarchy)
    try
        children = fig.children;
        for k = size(children, "*"):-1:1
            try
                if is_valid_handle(children(k)) then
                    ctype = "";
                    try ctype = children(k).type; catch end
                    if ctype == "Axes" then
                        delete(children(k));
                    end
                end
            catch
            end
        end
    catch
    end
endfunction


function a = gui_create_plot_axes(bounds_vec)
    // Safely clear existing axes on main figure, activate main figure, and create new axes.
    fig = get_main_figure();
    if ~is_valid_handle(fig) then
        a = gca();
        return;
    end

    clear_plot_axes();
    try
        scf(fig);
        fig.background = -2;
        try
            fig.color_map = jet(64);
        catch
            fig.color_map = jetcolormap(64);
        end
    catch
    end
    try
        a = newaxes(fig);
    catch
        try
            newaxes();
            a = gca();
        catch
            a = gca();
        end
    end
    try
        a.background = -2;
    catch
    end
    if exists('bounds_vec', 'local') then
        try
            a.axes_bounds = bounds_vec;
        catch
        end
    end
endfunction


function fig = get_main_figure()
    // Retrieve the main OrbitalMDT application figure handle by tag.
    fig = findobj('tag', 'main_fig');
    if fig <> [] then
        if size(fig, "*") > 1 then fig = fig(1); end
    end
endfunction
