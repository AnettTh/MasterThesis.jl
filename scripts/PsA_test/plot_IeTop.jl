using AURORA
using CairoMakie
using MasterThesis


##
savedir = "data/PsA_test"
Ie_top_result = load_Ie_top(savedir)


# (beam, time, energy)
Ie = Ie_top_result.Ietop[1, 1:21, :]

t = Ie_top_result.t[1:21]
E = Ie_top_result.E_centers


fig = Figure()

ax = Axis(
    fig[1,1],
    xlabel="Time [s]",
    ylabel="Energy [eV]",
    title="Ie_top_result"
)

heatmap!(ax, t, E, Ie)

figdir = mkpath(joinpath("data", "PsA_test", "figures"))
save(joinpath(figdir, "IeTop.png"), fig)

fig
