using Documenter
using DocThemeIndigo

using ZXCalculus
using ZXCalculus: ZXW, ZW
using Multigraphs

indigo = DocThemeIndigo.install(ZXCalculus)
makedocs(;
    modules = [ZXCalculus, ZXW, ZW],
    format=Documenter.HTML(;
        # ...
        # put your indigo css in assets
        assets=String[indigo #= your other assets =#],
        prettyurls = !("local" in ARGS)
    ),
    pages = ["Home" => "index.md",
        "Tutorials" => "tutorials.md",
        "Examples" => "examples.md",
        "APIs" => "api.md"
    ],
    repo = "https:/github.com/QuantumBFS/ZXCalculus.jl",
    sitename = "ZXCalculus.jl",
)

deploydocs(repo = "github.com/QuantumBFS/ZXCalculus.jl.git")
