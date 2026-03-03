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
            '-' => ("no p.", "impersonal"),
            '1' => ("1st p.", "first person"),
            '2' => ("2nd p.", "second person"),
            '3' => ("3rd p.", "third person"),
        ),
    ),
    :ten => Dict(
        :what => "Tense",
        :code => Dict(
            '-' => ("no t.", "no tense"),
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
            '-' => ("no v.", "no voice"),
            'A' => ("act.", "active"),
            'M' => ("mid.", "middle"),
            'P' => ("pass.", "passive"),
        ),
    ),
    :moo => Dict(
        :what => "Mood",
        :code => Dict(
            '-' => ("no m.", "no mood"),
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
            '-' => ("no c.", "no case"),
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
            '-' => ("no n.", "no number"),
            'S' => ("sg.", "singular"),
            'P' => ("pl.", "plural"),
        ),
    ),
    :gen => Dict(
        :what => "Gender",
        :code => Dict(
            '-' => ("no g.", "no gender"),
            'M' => ("m.", "masculine"),
            'F' => ("f.", "feminine"),
            'N' => ("n.", "neuter"),
        ),
    ),
    :deg => Dict(
        :what => "Degree",
        :code => Dict(
            '-' => ("no d.", "no degree"),
            'C' => ("comp.", "comparative"),
            'S' => ("sup.", "superlative"),
        ),
    ),
)

"""
`struct parsing <: GNTParsings`\n

The `GNTParsings` module parsing internal representation.
"""
struct parsing <: GNTParsings
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
    function parsing(pos::S, per::C, ten::C,
                     voi::C, moo::C, cas::C,
                     num::C, gen::C, deg::C) where {S<:AbstractString, C<:AbstractChar}
        cat = "$pos $per$ten$voi$moo$cas$num$gen$deg"
        @assert(
            pos in ("A-","C-","D-","I-","N-","P-","RA","RD","RI","RP","RR","V-","X-"),
            "'$cat': invalid part of speech '$pos'"
        )
        @assert(per in "-123"   , "'$cat': invalid person '$per'")
        @assert(ten in "-AFIPXY", "'$cat': invalid tense  '$ten'")
        @assert(voi in "-AMP"   , "'$cat': invalid voice  '$voi'")
        @assert(moo in "-DINOPS", "'$cat': invalid mood   '$moo'")
        @assert(cas in "-ADGNV" , "'$cat': invalid case   '$cas'")
        @assert(num in "-PS"    , "'$cat': invalid number '$num'")
        @assert(gen in "-FMN"   , "'$cat': invalid gender '$gen'")
        @assert(deg in "-CS"    , "'$cat': invalid degree '$deg'")
        return new(pos, per, ten, voi, moo, cas, num, gen, deg)
    end
end

export parsing

# External convenience constructors - two-arg splatting version
parsing(pos::X, par::Y) where {X<:AbstractString, Y<:AbstractString} = parsing(pos, par...)

# External convenience constructors - one-arg, space-delimited version
parsing(all::S) where S<:AbstractString = begin
    spl = split(all, limit=2)
    parsing(spl[1], join(split(spl[2]), ""))
end

# Base.show
import Base: show

function show(io::IO, x::parsing)
    a = "$(x.pos) "
    for f in (:per, :ten, :voi, :moo, :cas, :num, :gen, :deg)
        a *= @eval $x.$f
    end
    print(io, "parsing(\"$a\")")
end

# Meaning of
function meaningOf(x::parsing)
    dat = NTuple{4, Union{AbstractString,AbstractChar}}[]
    for key in (:pos, :per, :ten, :voi, :moo, :cas, :num, :gen, :deg)
        val = @eval($x.$key)
        push!(dat, (val, meaning[key][:what], meaning[key][:code][val]...))
    end
    return dat
end

export meaningOf

# Explain
function explain(x::parsing, abrflg=true,
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
    # parsings
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

function _srt_explain(x::parsing)
    ret = String[]
    push!(ret, meaning[:pos][:code][x.pos][1])
    for key in (:per, :ten, :voi, :moo, :cas, :num, :gen, :deg)
        val = @eval($x.$key)
        if val != '-'
            push!(ret, meaning[key][:code][val][1])
        end
    end
    return length(ret) > 1 ?
        @sprintf("%s %s", ret[1], join(ret[2:end], "")) :
        ret[1]
end

function _mid_explain(x::parsing)
    ret = String[]
    push!(ret, meaning[:pos][:code][x.pos][2])
    for key in (:per, :ten, :voi, :moo, :cas, :num, :gen, :deg)
        val = @eval($x.$key)
        if val != '-'
            push!(ret, meaning[key][:code][val][2])
        end
    end
    return length(ret) > 1 ?
        @sprintf("%s: %s", ret[1], join(ret[2:end], " ")) :
        ret[1]
end

function _eng_explain(x::parsing)
    ret = String[]
    push!(ret, meaning[:pos][:code][x.pos][2])
    for key in (:per, :ten, :voi, :moo, :cas, :num, :gen, :deg)
        val = @eval($x.$key)
        if val != '-'
            push!(ret, meaning[key][:code][val][2])
        end
    end
    return length(ret) > 1 ?
        @sprintf("%s %s", join(ret[2:end], " "), ret[1]) :
        ret[1]
end

function _lng_explain(x::parsing, ind::S=" "^4) where S<:AbstractString
    ret = String[]
    tmp = @sprintf("%s\n%s%s", meaning[:pos][:what], ind, meaning[:pos][:code][x.pos][2])
    push!(ret, tmp)
    for key in (:per, :ten, :voi, :moo, :cas, :num, :gen, :deg)
        val = @eval($x.$key)
        if val != '-'
            push!(ret, meaning[key][:code][val][2])
        end
    end
    return length(ret) > 1 ?
        @sprintf("%s: %s", ret[1], join(ret[2:end], " ")) :
        ret[1]
end

