using AURORA
using CairoMakie
using MasterThesis


"""
    generate_figures(filepath)

TBW
"""
function generate_figures(filepath)

    res = load_results(filepath)#; tidx = 1:10, eidx = 450:937)
    col = load_column_excitation(filepath)
    vol = load_volume_excitation(filepath)
    Iet = load_Ie_top(filepath)



    ## Make volum excitation
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
        field = :total
    )


    figpath = mkpath(joinpath(filepath, "figures"))

    save(joinpath(figpath, "VolumeExcitation.png"), fig)



    # Make column excitation
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


    figpath = mkpath(joinpath(filepath, "figures"))
    save(joinpath(figpath, "ColumnExcitation.png"), fig)



    # Make energy-height-Ie
    beam = 1
    time_idx = 8

    Ie = res.Ie[:, beam, time_idx, :]'
    E = res.E_centers
    n_z = res.h_atm

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

    figpath = mkpath(joinpath(filepath, "figures"))
    save(joinpath(figpath, "Energy-Height-Ie.png"), fig)


    # (beam, time, energy)
    Ie = Iet.Ietop[1, 1:11, :]

    t = Iet.t[1:11]
    E = Iet.E_centers

    fig = Figure()

    ax = Axis(
        fig[1,1],
        xlabel="Time [s]",
        ylabel="Energy [eV]",
        title="Ie_top_result"
    )

    heatmap!(ax, t, E, Ie)

    figpath = mkpath(joinpath(filepath, "figures"))
    save(joinpath(figpath, "IeTop.png"), fig)
end
