"""
`meaning`\n
A static data `Dict` with keys to various fields meanings
"""
meaning = Dict(
    :pos => Dict(
        :what => "Part of speech",
        :code => Dict(
            "A-" => ("adj.", "adjective"),
            "C-" => ("conj.", "conjunction"),
            "D-" => ("adv.", "adverb"),
            "I-" => ("interj.", "interjection"),
            "N-" => ("n.", "noun"),
            "P-" => ("prep.", "preposition"),
            "RA" => ("art.", "definite article"),
            "RD" => ("dem.pron.", "demonstrative pronoun"),
            "RI" => ("int./indef.pron.", "interrogative/indefinite pronoun"),
            "RP" => ("pers.pron.", "personal pronoun"),
            "RR" => ("rel.pron.", "relative pronoun"),
            "V-" => ("v.", "verb"),
            "X-" => ("part.", "particle"),
        )
    ),
    :per => Dict(
        :what => "Person",
        :code => Dict(
            '-' => ("", ""),
            '1' => ("1st p.", "first person"),
            '2' => ("2nd p.", "second person"),
            '3' => ("3rd p.", "third person"),
        ),
    ),
    :ten => Dict(
        :what => "Tense",
        :code => Dict(
            '-' => ("", ""),
            'P' => ("pres.", "present"),
            'I' => ("impf.", "imperfect"),
            'F' => ("fut.", "future"),
            'A' => ("aor.", "aorist"),
            'X' => ("perf.", "perfect"),
            'Y' => ("plpf.", "pluperfect"),
        ),
    ),
    :voi => Dict(
        :what => "Voice",
        :code => Dict(
            '-' => ("", ""),
            'A' => ("act.", "active"),
            'M' => ("mid.", "middle"),
            'P' => ("pass.", "passive"),
        ),
    ),
    :moo => Dict(
        :what => "Mood",
        :code => Dict(
            '-' => ("", ""),
            'I' => ("indic.", "indicative"),
            'D' => ("imper.", "imperative"),
            'S' => ("subj.", "subjunctive"),
            'O' => ("opt.", "optative"),
            'N' => ("inf.", "infinitive"),
            'P' => ("ptc.", "participle"),
        ),
    ),
    :cas => Dict(
        :what => "Case",
        :code => Dict(
            '-' => ("", ""),
            'N' => ("nom.", "nominative"),
            'G' => ("gen.", "genitive"),
            'D' => ("dat.", "dative"),
            'A' => ("acc.", "accusative"),
            'V' => ("voc.", "vocative"),
        ),
    ),
    :num => Dict(
        :what => "Number",
        :code => Dict(
            '-' => ("", ""),
            'S' => ("sg.", "singular"),
            'P' => ("pl.", "plural"),
        ),
    ),
    :gen => Dict(
        :what => "Gender",
        :code => Dict(
            '-' => ("", ""),
            'M' => ("m.", "masculine"),
            'F' => ("f.", "feminine"),
            'N' => ("n.", "neuter"),
        ),
    ),
    :deg => Dict(
        :what => "Degree",
        :code => Dict(
            '-' => ("", ""),
            'C' => ("comp.", "comparative"),
            'S' => ("sup.", "superlative"),
        ),
    ),
)

"""
`struct Parsing <: GNTParsings`\n

The `GNTParsings` module Parsing internal representation.
"""
struct Parsing <: GNTParsings
    pos::String     # Part of speech
    per::Char       # Person
    ten::Char       # Tense
    voi::Char       # Voice
    moo::Char       # Mood
    cas::Char       # Case
    num::Char       # Number
    gen::Char       # Gender
    deg::Char       # Degree
    # Internal (validating) constructor
    function Parsing(pos::S, per::C, ten::C,
                     voi::C, moo::C, cas::C,
                     num::C, gen::C, deg::C) where {S<:AbstractString, C<:AbstractChar}
        cat = "$pos $per$ten$voi$moo$cas$num$gen$deg"
        @assert(pos in keys(meaning[:pos][:code]), "'$cat': invalid part of speech '$pos'")
        @assert(per in keys(meaning[:per][:code]), "'$cat': invalid person '$per'")
        @assert(ten in keys(meaning[:ten][:code]), "'$cat': invalid tense  '$ten'")
        @assert(voi in keys(meaning[:voi][:code]), "'$cat': invalid voice  '$voi'")
        @assert(moo in keys(meaning[:moo][:code]), "'$cat': invalid mood   '$moo'")
        @assert(cas in keys(meaning[:cas][:code]), "'$cat': invalid case   '$cas'")
        @assert(num in keys(meaning[:num][:code]), "'$cat': invalid number '$num'")
        @assert(gen in keys(meaning[:gen][:code]), "'$cat': invalid gender '$gen'")
        @assert(deg in keys(meaning[:deg][:code]), "'$cat': invalid degree '$deg'")
        return new(pos, per, ten, voi, moo, cas, num, gen, deg)
    end
end

export Parsing

# External convenience constructors - two-arg splatting version
Parsing(pos::X, par::Y) where {X<:AbstractString, Y<:AbstractString} = Parsing(pos, par...)

# External convenience constructors - one-arg, space-delimited version
Parsing(all::S) where S<:AbstractString = begin
    spl = split(all, limit=2)
    Parsing(spl[1], join(split(spl[2]), ""))
end

# Base.show
import Base: show

function show(io::IO, x::Parsing)
    a = "$(x.pos) "
    for f in (:per, :ten, :voi, :moo, :cas, :num, :gen, :deg)
        a *= @eval $x.$f
    end
    print(io, "Parsing(\"$a\")")
end

# Meaning of
function meaningOf(x::Parsing)
    dat = NTuple{4, Union{AbstractString,AbstractChar}}[]
    for key in (:pos, :per, :ten, :voi, :moo, :cas, :num, :gen, :deg)
        val = @eval($x.$key)
        push!(dat, (val, meaning[key][:what], meaning[key][:code][val]...))
    end
    return dat
end

export meaningOf

# Explain
function explain(x::Parsing, abrflg=true,
                 posflg=false, possep=": ", posaft=": ",
                 parflg=false, parsep=": ", paraft="",
                 joinsp="")
    idx = abrflg ? 3 : 4
    mox = meaningOf(x)
    ret = String[]
    # part of speech
    tmp  = posflg ? "$(mox[1][2])$(possep)" : ""
    tmp *= "$(mox[1][idx])$(posaft)"
    push!(ret, tmp)
    # Parsings
    for par in mox[2:end]
        tmp  = parflg ? "$(par[2])$(parsep)" : ""
        tmp *= "$(par[idx])$(paraft)"
        push!(ret, tmp)
    end
    return join(ret, joinsp)
end

export explain

estyles = Dict(
        :EXP => (
            abrflg=false,   posflg=true,        possep=":\n    ",   posaft="\n",
            parflg=true,    parsep=":\n    ",   paraft="\n",        joinsp=""
           ),
        :LST => (
            abrflg=false,   posflg=true,        possep=": ",        posaft="\n",
            parflg=true,    parsep=": ",        paraft="\n",        joinsp=""
           ),
        :PLN => (
            abrflg=false,   posflg=false,       possep=": ",        posaft=" ",
            parflg=false,   parsep=": ",        paraft=" ",         joinsp=""
           ),
        :exp => (
            abrflg=true,    posflg=true,        possep=":\n    ",   posaft="\n",
            parflg=true,    parsep=":\n    ",   paraft="\n",        joinsp=""
           ),
        :lst => (
            abrflg=true,    posflg=true,        possep=": ",        posaft="\n",
            parflg=true,    parsep=": ",        paraft="\n",        joinsp=""
           ),
        :pln => (
            abrflg=true,    posflg=false,       possep=": ",        posaft=" ",
            parflg=false,   parsep=": ",        paraft=" ",         joinsp=""
           ),
    )

export estyles

