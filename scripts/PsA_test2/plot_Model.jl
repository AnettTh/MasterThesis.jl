using MasterThesis
using AURORA
using CairoMakie

## Find or generate MSIS and IRI data files
year = 2020
month = 10
day = 22
hour = 03
minute = 00
lat = 69.4
lon = 18.6
height = 85:1:700

##
msis_file = find_msis_file(
    year=year,
    month=month,
    day=day,
    hour=hour,
    minute=minute,
    lat=lat,
    lon=lon,
    height=height
)

##
iri_file = find_iri_file(
    year=year,
    month=month,
    day=day,
    hour=hour,
    minute=minute,
    lat=lat,
    lon=lon,
    height=height
)


## Make the model
model = AuroraModel(
    [100, 500],      # Altitude limits [km]
    180:-30:0,       # Pitch-angle bin edges [°] → 6 beams
    10000,           # Maximum energy [eV]
    msis_file,
    iri_file,
    13               # Magnetic field angle to zenith [°]
)


## Define precipitating electron flux
flux = InputFlux(
    FlatSpectrum(1e-3; E_min=5000),
    SinusoidalFlickering(5.0),
    beams=1,                            # Input is only 1 beam, but result tracks 6 bins???
    z_source= 6.5 * RE * 1e-3,          # At L-shell 6.5 (Tromsø-ish)
)


## Create and run the simulation
savedir = mkpath(joinpath("data", "PsA_test2"))

sim = AuroraSimulation(
    model,
    flux,
    savedir;
    mode=TimeDependentMode(
        duration=10,
        dt=0.05,
        CFL_number=256,
        max_memory_gb=4.0,
    )
)


## To 'make' the simulation without recalculating the data
initialize!(sim)


## Plots for the model
figs_model = plot_model(model)

display(figs_model[:scattering])
display(figs_model[:energy_grid])
display(figs_model[:atmosphere])
display(figs_model[:phase_functions])
display(figs_model[:energy_levels])
display(figs_model[:cross_sections])


## Plot for the input
fig_input = plot_input(sim)

display(fig_input)
