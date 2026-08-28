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

    res = load_results(filepath; zidx=n_z:n_z, μidx=μ_bins, tidx=1:100)

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


function plot_ColumnExcitation(filepath)

    col = load_column_excitation(filepath)

    t = col.t

    fig = Figure()

    ax = Axis(
    fig[1, 1],
    xlabel = "Time [s]",
    ylabel = "Column intensity [photons m⁻² s⁻¹]",
    title = "Column-integrated emission intensities",
    )

    lines!(ax, t, col.I_4278, label = "4278 Å")
    lines!(ax, t, col.I_6730, label = "6730 Å")
    lines!(ax, t, col.I_7774, label = "7774 Å")
    lines!(ax, t, col.I_8446, label = "8446 Å")
    #lines!(ax, t, col.I_O1D,  label = "O(¹D)")
    #lines!(ax, t, col.I_O1S,  label = "O(¹S)")


    axislegend(ax)
    figpath = mkpath(joinpath(filepath, "figures"))

    save(
        joinpath(figpath, "ColumnExcitation_edited.png"),
        fig,
    )

end


function plot_ColumnExcitationRatio(filepath; normalize::Bool=true)

    col = load_column_excitation(filepath)

    t = col.t

    ratios = [
        ("4278 / 6730", col.I_4278 ./ col.I_6730),
        ("4278 / 7774", col.I_4278 ./ col.I_7774),
        ("4278 / 8446", col.I_4278 ./ col.I_8446),
        ("6730 / 7774", col.I_6730 ./ col.I_7774),
        ("6730 / 8446", col.I_6730 ./ col.I_8446),
        ("7774 / 8446", col.I_7774 ./ col.I_8446),
    ]

    fig = Figure(size = (800, 500))

    if normalize
        ax = Axis(
            fig[1, 1],
            xlabel = "Time [s]",
            ylabel = "Normalized ratio",
            title = "Normalized column-emission ratios",
        )
    else
        ax = Axis(
            fig[1, 1],
            xlabel = "Time [s]",
            ylabel = "Ratio",
            title = "Column-emission ratios",
        )
    end

    for (label, r) in ratios

        if normalize
            r = copy(r)
            r[.!isfinite.(r)] .= NaN   # remove Inf/NaN from division issues

            # normalize by maximum finite value
            rmax = maximum(skipmissing(r[isfinite.(r)]))
            r_plot = r ./ rmax
        else
            r_plot = r
        end

        lines!(ax, t, r_plot, label = label)
    end

    axislegend(ax, position = :rb)

    fig

    figpath = mkpath(joinpath(filepath, "figures"))

    if normalize
        save(
            joinpath(figpath, "ColumnExcitation_ratio_normalized.png"),
            fig,
        )
    else
        save(
            joinpath(figpath, "ColumnExcitation_ratio.png"),
            fig,
        )
    end
end


function plot_VolumExcitation(filepath)

    vol = load_volume_excitation(filepath)

    z = vol.h_atm[1:200]
    t = vol.t

    # Dimension is [height, time]
    emissions = [
        ("4278 Å", vol.Q4278[1:200, :]),
        ("6730 Å", vol.Q6730[1:200, :]),
        ("7774 Å", vol.Q7774[1:200, :]),
        ("8446 Å", vol.Q8446[1:200, :])
        ]

    # Find common scaling for plot
    cmin = minimum(minimum(Q) for (_, Q) in emissions)
    cmax = maximum(maximum(Q) for (_, Q) in emissions)

    fig = Figure(size=(800, 450))

    Label(
        fig[0, 1:2],
        "Volume emission rates",
        fontsize = 24,
        font = :bold
    )


    axes = Axis[]

    for (i, (λ, Q)) in enumerate(emissions)
        row = ceil(Int, i / 2)
        col = i - 2 * (row - 1)

        ax = Axis(
            fig[row, col],
            xlabel="Time [s]",
            ylabel="Height [km]",
            title=λ
        )

        push!(axes, ax)

        hm = heatmap!(
            ax,
            t,
            z / 1e3,
            Q',
            colormap = :turbo,
            colorrange = (cmin, cmax))
    end

    Colorbar(
        fig[1:2, 3],
        limits = (cmin, cmax),
        colormap = :turbo,
        label = "Emission rate [m⁻³ s⁻¹]"
    )

    linkxaxes!(axes...)
    linkyaxes!(axes...)

    hidexdecorations!(axes[1], grid = false)
    hidexdecorations!(axes[2], grid = false)

    hideydecorations!(axes[2], grid = false)
    hideydecorations!(axes[4], grid = false)


    figpath = mkpath(joinpath(filepath, "figures"))

    save(
        joinpath(figpath, "VolumExcitation_edited.png"),
        fig,
    )
end


function plot_IeE_updown(filepath)

    currents = NCDataset(joinpath(filepath, "analysis/currents.nc"), "r")

    z = currents["altitude"]
    t = currents["time"]

    # Dimensions [h, t]
    IeE_up = currents["IeE_up"]
    IeE_down = currents["IeE_down"]

    fig = Figure()

    ax = Axis(
        fig[1,1],
        xlabel="Time [s]",
        ylabel="Height [km]"
    )

    hm = heatmap!(
        ax,
        t,
        z / 1e3,
        IeE_up'
    )

    fig

end

#res = load_results(filepath; tidx = 1:21, eidx = 450:937)
#col = load_column_excitation(filepath)
#vol = load_volume_excitation(filepath)
#Iet = load_Ie_top(filepath)
