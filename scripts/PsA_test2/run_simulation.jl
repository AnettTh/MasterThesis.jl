using MasterThesis
using AURORA
using CairoMakie

#===========================================================================================
EVALUATION
----------
Second run uses a greater range of energies, as the previous one was too hard. Also,
simulating for a shorter period of time (with higher resolution), as the previous test ran
for too long (nothing of interest, for now, happened after some 2 seconds anyways).

Ran for approximately XXX h.

Input flux:
- Spectrum: FlatSpectrum(1e-3; E_min=100)
- Modulation: SinusoidalFlickering(5.0)
- Beams: 1
- Source: L-shell 6.5

Time:
- Duration: 2 s
- Δt: 0.01 s

Comments:
-

===========================================================================================#


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
    FlatSpectrum(1e-3; E_min=100),
    SinusoidalFlickering(5.0),
    beams=1,
    z_source= 6.5 * (RE * 1e-3),    # [km]
)


## Create and run the simulation
savedir = mkpath(joinpath("data", "PsA_test2"))

sim = AuroraSimulation(
    model,
    flux,
    savedir;
    mode=TimeDependentMode(
        duration=5,
        dt=0.01,
        CFL_number=256,
        max_memory_gb=4.0,
    )
)


## Run the simulation OR initialize if the simulation already exist
run!(sim)


## Save additional values
make_Ie_top_file(sim)              # boundary condition (input flux applied at top)
make_volume_excitation_file(sim)   # volumetric excitation rates for optical emissions
make_column_excitation_file(sim)   # column-integrated excitation rates
make_current_file(sim)             # field-aligned electron currents and energy fluxes
make_heating_rate_file(sim)        # electron heating rates
make_psd_file(sim)                 # electron phase-space density f(E, θ) and F(v∥)
