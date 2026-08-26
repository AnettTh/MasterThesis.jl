using AURORA
using CairoMakie
using MasterThesis


##
res = load_results("data/PsA_test"; tidx = 1:21, eidx = 450:937)

beam = 1
time_idx = 8

Ie = res.Ie[:, beam, time_idx, :]'
E = res.E_centers
n_z = res.h_atm


##
fig = Figure()

ax = Axis(
    fig[1,1],
    xlabel="Energy [eV]",
    ylabel="Height [km]",
    title="Electron flux at time index $time_idx")

hm = heatmap!(ax, E, n_z/1e3, Ie)

Colorbar(
    fig[1, 2],
    hm,
    label = "Electron flux [m⁻² s⁻¹]"
)

figdir = mkpath(joinpath("data", "PsA_test", "figures"))
save(joinpath(figdir, "Energy-Height-Ie.png"), fig)

fig
