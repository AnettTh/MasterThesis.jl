using AURORA
using CairoMakie
using MasterThesis


##
col = load_column_excitation("data/PsA_test")


##
fig = Figure()


ax = Axis(
    fig[1, 1],
    xlabel = "Time [s]",
    ylabel = "Altitude [km]",
    title = "Column excitation",
)

plot_column_excitation!(
    ax,
    col;
)


figdir = mkpath(joinpath("data", "PsA_test", "figures"))
save(joinpath(figdir, "ColumnExcitation.png"), fig)

fig
