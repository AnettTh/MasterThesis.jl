module MasterThesis

include("constants.jl")
export RE

include("plot/plot_results.jl")
export plot_ElectronFlux, plot_all_ElectronFlux

include("plot/plot_quicklook.jl")
export generate_figures

end
