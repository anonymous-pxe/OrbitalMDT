// ============================================================================
// OrbitalMDT :: Orbital Mechanics Mission Design Toolkit
// Version 1.0.1
// ============================================================================

funcprot(0);
mode(-1);
clear;

base_dir = get_absolute_file_path("main.sce");

core_files = [
    "constants.sci", ..
    "status.sci", ..
    "validation.sci", ..
    "time.sci", ..
    "frames.sci", ..
    "kepler.sci", ..
    "coordinates.sci", ..
    "ephemeris.sci", ..
    "lambert.sci", ..
    "hohmann.sci", ..
    "bielliptic.sci", ..
    "propagator.sci", ..
    "porkchop.sci", ..
    "flyby.sci", ..
    "rocket_equation.sci", ..
    "reentry.sci", ..
    "rendezvous.sci", ..
    "groundtrack.sci", ..
    "mission_utils.sci"
];

gui_files = [
    "gui_main.sci", ..
    "gui_mission_planner.sci", ..
    "gui_hohmann.sci", ..
    "gui_lambert.sci", ..
    "gui_propagator.sci", ..
    "gui_solarsystem.sci", ..
    "gui_rocket.sci", ..
    "gui_reentry.sci"
];

mprintf("\n========================================\n");
mprintf("  OrbitalMDT v1.0.1 -- Loading...\n");
mprintf("========================================\n\n");

for k = 1:size(core_files, "*")
    f = base_dir + "core" + filesep() + core_files(k);
    if isfile(f) then
        exec(f, -1);
        mprintf("  [OK] core/%s\n", core_files(k));
    else
        mprintf("  [!!] MISSING: core/%s\n", core_files(k));
    end
end

for k = 1:size(gui_files, "*")
    f = base_dir + "gui" + filesep() + gui_files(k);
    if isfile(f) then
        exec(f, -1);
        mprintf("  [OK] gui/%s\n", gui_files(k));
    else
        mprintf("  [!!] MISSING: gui/%s\n", gui_files(k));
    end
end

app_file = base_dir + "app" + filesep() + "app_state.sci";
if isfile(app_file) then
    exec(app_file, -1);
    mprintf("  [OK] app/app_state.sci\n");
    init_app_state();
end

mprintf("\n  Loaded %d core + %d gui = %d modules\n", ..
    size(core_files, "*"), size(gui_files, "*"), size(core_files, "*")+size(gui_files, "*"));
mprintf("========================================\n");
mprintf("  Launching GUI...\n");
mprintf("========================================\n\n");

launch_orbital_mdt();
