using CairoMakie


function plot_ElectronFlux(filepath, n_z; n_μ=1)

    res = load_results(filepath; zidx=n_z:n_z, μidx=n_μ:n_μ)

    t = res.t
    E = res.E_centers
    ΔE = res.ΔE
    Ie = res.Ie[1,1,:,:]

    # Used as title
    z = round(Int, res.h_atm[1] / 1e3)

    I_diffE = Ie ./ ΔE'

    I_plot = copy(I_diffE)
    I_plot[I_plot .<= 0] .= NaN

    fig = Figure()

    ax = Axis(
        fig[1,1],
        xlabel="Time [s]",
        ylabel="Energy [eV]",
        yscale=log10,
        title="Electron flux, z = $z km")

    hm = heatmap!(
        ax,
        t,
        E,
        I_plot,
        colorscale = log10,
        colormap = :turbo,
        colorrange = (1e6, 5e10)
    )

    Colorbar(
        fig[1, 2],
        hm,
        label = "Electron flux [m⁻² eV⁻¹ s⁻¹]"
    )

    figpath = mkpath(joinpath(filepath, "figures"))
    save(joinpath(figpath, "ElectronFlux_$z.png"), fig)
end


function plot_all_ElectronFlux(filepath, n_z; μ_bins=1:6)

    res = load_results(filepath; zidx=n_z:n_z, μidx=μ_bins)

    t = res.t
    E = res.E_centers
    ΔE = res.ΔE


    θ_edges = range(0, 180, length = length(μ_bins) + 1)


    # Used as title
    z = round(Int, res.h_atm[1] / 1e3)

    fig = Figure(size = (1200, 700))

    hm = nothing

    for (i, n_μ) in enumerate(μ_bins)

        row = div(i - 1, 3) + 1
        col = mod(i - 1, 3) + 1

        Ie = res.Ie[1, i, :, :]

        I_diffE = Ie ./ ΔE'

        I_plot = copy(I_diffE)
        I_plot[I_plot .<= 0] .= NaN

        θ1 = θ_edges[i]
        θ2 = θ_edges[i + 1]

        ax = Axis(
            fig[row, col],
            xlabel="Time [s]",
            ylabel="Energy [eV]",
            yscale=log10,
            title="$(θ1)°–$(θ2)°")

        hm = heatmap!(
            ax,
            t,
            E,
            I_plot,
            colorscale = log10,
            colormap = :turbo,
            colorrange = (1e6, 5e10)
        )
    end

    Colorbar(
        fig[:, 4],
        hm,
        label = "Electron flux [m⁻² eV⁻¹ s⁻¹]"
    )

    Label(
        fig[0, 1:3],
        "Electron flux, z = $z km",
        fontsize = 22,
    )
    figpath = mkpath(joinpath(filepath, "figures"))

    save(
        joinpath(figpath, "ElectronFlux_z$(z)_all_mu.png"),
        fig,
    )

    fig
end
