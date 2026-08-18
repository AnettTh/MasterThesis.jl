using MasterThesis
using AURORA

## Find or generate MSIS and IRI data files
# Default parameters: VISIONS-2 rocket launch conditions
# (2018-12-07 11:15 UTC, 76°N 5°E)
msis_file = find_msis_file(year=2006, month=10, day=22, hour=22, minute=7, lat=69, lon=19, height=85:1:700)        
iri_file  = find_iri_file(year=2006, month=10, day=22, hour=22, minute=7, lat=69, lon=19, height=85:1:700)


## Make the model
model = AuroraModel(
    [100, 500],      # Altitude limits [km]
    180:-30:0,      # Pitch-angle bin edges [°] → 12 beams
    5000,           # Maximum energy [eV]
    msis_file,      
    iri_file, 
    13              # Magnetic field angle to zenith [°]
)


## Define precipitating electron flux
flux = InputFlux(
    FlatSpectrum(4e-3; E_min=1e3),      # Total energy flux of 4 erg / cm² s and a minimum energy of 1 keV  
    SinusoidalFlickering(0.2),          # Period of 5 s, i.e. 0.2 Hz
    beams=1,                            # Don't know why this is one, figure it out!
    z_source=3000.0,                    # Might want to try this out with some other height?
)


## Create and run the simulation
savedir = mkpath(joinpath("data", "PsA_test"))

sim = AuroraSimulation(
    model, 
    flux, 
    savedir;
    mode=TimeDependentMode(
        duration=1.0, 
        dt=0.01,
        CFL_number=256,
        max_memory_gb=4.0,
    )
)


## Run the simulation
run!(sim)


## Save additional values
make_Ie_top_file(sim)              # boundary condition (input flux applied at top)
make_volume_excitation_file(sim)   # volumetric excitation rates for optical emissions
make_column_excitation_file(sim)   # column-integrated excitation rates
make_current_file(sim)             # field-aligned electron currents and energy fluxes
make_heating_rate_file(sim)        # electron heating rates
make_psd_file(sim)                 # electron phase-space density f(E, θ) and F(v∥)