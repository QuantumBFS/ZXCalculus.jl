using Documenter, ZXCalculus

makedocs(;
    modules = [ZXCalculus],
    format = Documenter.HTML(prettyurls = !("local" in ARGS)),
    pages = ["Home" => "index.md",
        "Tutorials" => "tutorial.md",
        "APIs" => "api.md"
    ],
    repo = "https:/github.com/QuantumBFS/ZXCalculus.jl",
    sitename = "ZXCalculus.jl",
)

deploydocs(repo = "github.com/QuantumBFS/ZXCalculus.jl.git")
