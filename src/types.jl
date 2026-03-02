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
    :tense => Dict(
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
    :voice => Dict(
        :what => "Voice",
        :code => Dict(
            '-' => ("no v.", "no voice"),
            'A' => ("act.", "active"),
            'M' => ("mid.", "middle"),
            'P' => ("pass.", "passive"),
        ),
    ),
    :mood => Dict(
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
    :case => Dict(
        :what => "Case",
        :code => Dict(
            '-' => ("no c.", "no case"),
            'N' => ("nom.", "nominative"),
            'G' => ("gen.", "genitive"),
            'D' => ("dat.", "dative"),
            'A' => ("acc.", "accusative"),
        ),
    ),
    :number => Dict(
        :what => "Number",
        :code => Dict(
            '-' => ("no n.", "no number"),
            'S' => ("sg.", "singular"),
            'P' => ("pl.", "plural"),
        ),
    ),
    :gender => Dict(
        :what => "Gender",
        :code => Dict(
            '-' => ("no g.", "no gender"),
            'M' => ("m.", "masculine"),
            'F' => ("f.", "feminine"),
            'N' => ("n.", "neuter"),
        ),
    ),
    :degree => Dict(
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

# Explain

function _explain(io::IO, x::parsing)
    
end

explain(x::parsing, io::IO = Base.stdout) = _explain(io, x)

