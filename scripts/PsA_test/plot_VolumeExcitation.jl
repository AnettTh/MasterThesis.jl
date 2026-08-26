using AURORA
using CairoMakie
using MasterThesis


##
#savedir = mkpath(joinpath("data", "PsA_test"))
#data = load_volume_excitation(savedir)
vol = load_volume_excitation("data/PsA_test")

##
fig = Figure()


ax = Axis(
    fig[1, 1],
    xlabel = "Time [s]",
    ylabel = "Altitude [km]",
    title = "Volume excitation",
)

plot_excitation!(
    ax,
    vol;
    field = :total,      # Can be :Q4278, :Q6730, :Q7774, :Q8446, :QO1D, :QO1S, :QOi, :QO2i,
                        # :QN2i, or :total
)


figdir = mkpath(joinpath("data", "PsA_test", "figures"))
save(joinpath(figdir, "VolumeExcitation.png"), fig)


display(fig)
