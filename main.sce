// ============================================================================
// OrbitalMDT :: Orbital Mechanics Mission Design Toolkit
// Version 0.2.0
// ============================================================================

funcprot(0);
mode(-1);
clear;

base_dir = get_absolute_file_path("main.sce");

core_files = [
    "constants.sci", ..
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
mprintf("  OrbitalMDT v0.2.0 -- Loading...\n");
mprintf("========================================\n\n");

for k = 1:length(core_files)
    f = base_dir + "core" + filesep() + core_files(k);
    if isfile(f) then
        exec(f, -1);
        mprintf("  [OK] core/%s\n", core_files(k));
    else
        mprintf("  [!!] MISSING: core/%s\n", core_files(k));
    end
end

for k = 1:length(gui_files)
    f = base_dir + "gui" + filesep() + gui_files(k);
    if isfile(f) then
        exec(f, -1);
        mprintf("  [OK] gui/%s\n", gui_files(k));
    else
        mprintf("  [!!] MISSING: gui/%s\n", gui_files(k));
    end
end

mprintf("\n  Loaded %d core + %d gui = %d modules\n", ..
    length(core_files), length(gui_files), length(core_files)+length(gui_files));
mprintf("========================================\n");
mprintf("  Launching GUI...\n");
mprintf("========================================\n\n");

launch_orbital_mdt();
